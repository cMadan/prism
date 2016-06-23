function mdl = prism_train(tr_X,tr_y,opt)
% Build multiple regression model from training data.
%
% Inputs:
%   tr_X    = X data to train on
%             each column is considered as an indepdent predictor
%             should be size NxM
%   tr_y    = Y data to train on
%             should be size Nx1
%
%   opt     = set options for multiple regression model
%
%              .doSpline        = enables/disables the spline regression
%                                 (default: 1)
%              .doPCA           = enable/disable the PCA (default: 1)
%              .doRVR           = use RVR (default: 1), or LASSO (0)
%
%              .spline.p        = smoothing parameter to use in spline
%                                 regression
%                                 if not specified, will be selected by csaps
%                                 if is a vector, must be length M, where
%                                 each index will be used for the
%                                 respective column in X
%                                 if is a single value, will use it for all
%                                   0 results in least-squares cubic spline
%                                   1 results in variational/'natural'
%                                     cubic spline interpolant
%                                 See 'csaps' for further details.
%                                 default: [ 10:10:90 100:100:1000 Inf ]
%              .pc.thresh       = Threshold for number of principle
%                                 components to keep, based on miniumum
%                                 amount of explained variance, as a
%                                 percent (default: 95)
%              .lasso.k         = Set 'l' for LASSO k-fold CV (default: 10)
%
%              .disableWarnings = disable common warnings (default: 0)
%
%
% Outputs:
%   mdl     = fitted Prism model given training data
%             struct with two subfields:
%               .stats          = model parameters for spline, pca, rvr/lasso
%               .pred           = predicted y (i.e., y_hat)
%               .opt            = store options underlying model
%
% Matlab toolbox dependencies: stats, curvefit, signal
% For RVR, also requires SparseBayes V2 (http://www.relevancevector.com).
%
% 20160621 CRM
%
% Written by Christopher R Madan
% https://github.com/cMadan/prism

%% define default options
%defaultopt.spline.p       = defer to csaps
defaultopt.pc.thresh        = 95;
defaultopt.lasso.k          = 10;

defaultopt.doSpline         = 1;
defaultopt.doPCA            = 1;
defaultopt.doRVR            = 1;
defaultopt.disableWarnings  = 0;

if exist('opt')
    opt = setstructfields(defaultopt,opt);
else
    opt = defaultopt;
end
mdl.opt = opt;

% some warnings 'commonly' occur
%       I don't want disabling these to be the default
%       but, also are not really a problem
if opt.disableWarnings == 1
    % save warning state, so can restore it later
    wState = warning;
    % disable common warnings
    warning('off','MATLAB:nearlySingularMatrix');
    warning('off','SPLINES:SPAPS:toltoolow');
end


%% spline regression
if opt.doSpline == 1
    % calculate spline regr
    for p = 1:size(tr_X,2)
        if ~isfield(opt,'spline')   % not specified
            [s{p},rho(p)]   = csaps(tr_X(:,p),tr_y);
        else
            if length(opt.spline.p) == 1
                [s{p},rho(p)]   = csaps(tr_X(:,p),tr_y,opt.spline.p);
            else
                [s{p},rho(p)]   = csaps(tr_X(:,p),tr_y,opt.spline.p(p));
            end
        end
        tr_Xs(:,p)      = fnval(s{p},tr_X(:,p));
    end
    
    % store spline params
    spline.s    = s;
    spline.rho  = rho;
    mdl.stats.spline    = spline;
    
    % replace X with spline regressions prediction
    tr_X        = tr_Xs;
end

%% PCA
if opt.doPCA == 1
    % calculate PCA
    [coeff, score, latent, tsquared, explained] = pca(tr_X);
    
    % only keep PCs up to threshold
    pc.coeff= coeff;
    pc.keep = min(find(cumsum(explained)>opt.pc.thresh));
    tr_Xp   = tr_X*pc.coeff;
    tr_Xp   = tr_Xp(:,1:pc.keep);
    mdl.stats.pc        = pc;
    
    % replace X with the PCs
    tr_X    = tr_Xp;
end

%% multiple regression
if opt.doRVR == 1
    % use RVR for multiple regression
    
    verbose                     = 0;
    BASIS                       = tr_X;
    Outputs                     = tr_y;
    likelihood_                 = 'Gaussian';
    iterations                  = 10000;
    OPTIONS		= SB2_UserOptions('iterations',iterations,...
                                  'diagnosticLevel', verbose,...
                                  'monitor', 10);
    
    % run SparseBayes_v2
    [PARAMETER, HYPERPARAMETER, DIAGNOSTIC] = ...
        SparseBayes(likelihood_, BASIS, Outputs, OPTIONS);
    M                           = size(BASIS,2);
    w_infer						= zeros(M,1);
    w_infer(PARAMETER.Relevant)	= PARAMETER.Value;
    
    % determine predictions for no-hold-out
    mdl.pred                    = BASIS*w_infer;
    PARAMETER.y                 = mean(tr_y) - mean(BASIS*w_infer);
    mdl.pred                    = mdl.pred + PARAMETER.y;
    
    mdl.stats.rvr               = PARAMETER;

else
    % use LASSO instead
    [B,FitInfo]             = lasso(tr_X,tr_y,'cv',opt.lasso.k);
    lassoMinMSE.b           = B(:,FitInfo.IndexMinMSE);
    lassoMinMSE.y           = FitInfo.Intercept(FitInfo.IndexMinMSE);
    mdl.stats.lasso         = FitInfo;
    mdl.stats.lassoMinMSE   = lassoMinMSE;

    % determine predictions for no-hold-out
    mdl.pred                = sum(tr_X.*repmat(lassoMinMSE.b',size(tr_X,1),1),2) + lassoMinMSE.y;
end


%%
% restore warning state
if opt.disableWarnings == 1
    warning(wState);
end
