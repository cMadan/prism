function perf = prism_eval(y,fit)
% Calculate basic performance for Prism model.
%
% Inputs:
%   y       = 'y' from model (i.e., dependent variable)
%   pred    = expects 'fit' from prism_test
%
% Outputs:
%   perf    = struct with three fields:
%              .r2   = r^2, explained variance
%              .mae  = mean absolute error
%              .mdae = median absolute error
%              .rmsd = root mean squared deviation
%              .bic  = BIC
%
% 20190924 CRM
%
% Written by Christopher R Madan
% https://github.com/cMadan/prism

% patch for convience/error-handling
if ~isstruct(fit)
    pred = fit;
    fit = [];
    fit.pred = pred;
end

% r^2, explained variance
%perf.r2     = corr(y,fit.pred)^2; % replaced, see below

% MAE, mean absolute error
% how far are we off, on average?
perf.mae    = mean(abs(y - fit.pred));

% MdAE, median absolute error
% how far are we off, on average (non-parametric)?
perf.mdae    = median(abs(y - fit.pred));

% RMSD, root mean squared deviation
% similar to MAE, but more sensitive to outliers
perf.rmsd   = sqrt(mean((y - fit.pred).^2));

% BIC, special case assuming OLS
TSS         = sum((y - mean(y)).^2);        % total sum of squares
RSS         = sum((fit.pred - y).^2);       % residual
perf.r2     = 1-(RSS/TSS);                  % proportion explained variance
nparam      = length(fit.pred);
nobs        = length(y);
bic         = nobs * log( RSS / nobs ) + nparam * log(nobs);
perf.bic    = bic;

