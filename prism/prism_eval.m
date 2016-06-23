function perf = prism_eval(y,pred)
% Calculate basic performance for Prism model.
% 
% Inputs:
%   y       = 'y' from model (i.e., dependent variable)
%   pred    = pred field from prism_train/test
%                 also accepts the 'mdl' model output itself,
%                 for convienence
%
% Outputs:
%   perf    = struct with three fields:
%              .r2   = r^2, explained variance
%              .mae  = mean absolute error
%              .mdae = median absolute error
%              .rmsd = root mean squared deviation
%
% 20160619 CRM

% patch for convience/error-handling
if isfield(pred,'pred')
    pred = pred.pred;
end

% r^2, explained variance
perf.r2     = corr(y,pred)^2;

% MAE, mean absolute error
% how far are we off, on average?
perf.mae    = mean(abs(y - pred));

% MdAE, median absolute error
% how far are we off, on average (non-parametric)?
perf.mdae    = median(abs(y - pred));

% RMSD, root mean squared deviation
% similar to MAE, but more sensitive to outliers
perf.rmsd   = sqrt(mean((y - pred).^2));

