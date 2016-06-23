function fit = prism_test(te_X,params)
% Apply previous model to test data.
%
% Inputs:
%   te_X    = X data to test with
%             should be same organization as tr_X
%   params  = output from prism_train
%             prefers mdl.stats
%                also accepts the 'mdl' model output itself,
%                for convienence
% Outputs:
%   fit     = output after applying Prism to training data
%             struct with one subfield:
%               .pred  = predicted y (i.e., y_hat)
%
% 20160621 CRM

% patch for convience/error-handling
if isfield(params,'stats')
    params = params.stats;
end

%% spline regression
if isfield(params,'spline')
    % doSpline
    s = params.spline.s;
    for p = 1:size(te_X,2)
        te_Xs(:,p) = fnval(s{p},te_X(:,p));
    end
    te_X    = te_Xs;
end

%% PCA
if isfield(params,'pc')
    % doPCA
    pc = params.pc;
    te_Xp   = te_X*pc.coeff;
    te_Xp   = te_Xp(:,1:pc.keep);
    te_X    = te_Xp;
end

%% multiple regression
if isfield(params,'rvr')
    % doRVR
    PARAMETER = params.rvr;
    
    BASIS                       = te_X;
    M                           = size(BASIS,2);
    w_infer						= zeros(M,1);
    w_infer(PARAMETER.Relevant)	= PARAMETER.Value;
    fit.pred                    = BASIS*w_infer + PARAMETER.y;

elseif isfield(params,'lasso')
    % use LASSO instead
    lassoMinMSE = params.lassoMinMSE;
    fit.pred = sum(te_X.*repmat(lassoMinMSE.b',size(te_X,1),1),2) + lassoMinMSE.y;
end
