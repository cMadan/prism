% Demo of Prism functionality
% 20160621 CRM

%% init
% import prism
addpath(fullfile('..','prism'))

% load demo data
load('demo')
% demo contains four variables:
%
% tr_X and tr_y are our training data
% te_X and te_y are our test data
%
% tr data has 500 cases, te data has 100 cases
% X has 175 predictors

%% Train

% clear opt, in case it has any previous values
clear opt
% some warnings 'commonly' occur
%       I don't want disabling these to be the default
%       but, also are not a problem in most cases 
%       (won't be best model anyway)
% so let's disable them with the options
opt.disableWarnings = 1;

% force least-squares spline, often reduces over-fitting
opt.spline.p        = 0;

% options to experiment with:
%opt.doSpline        = 0;
%opt.doPCA           = 0;
%opt.doRVR           = 0;

% fit prism to training data
mdl     = prism_train(tr_X,tr_y,opt);
% get performance metrics (r^2, RMSD, MAE)
% is an estimate of best-case of sorts:
%       poor performance here is a bad sign
%       but, good performance could represent over-fitting
tr_perf = prism_eval(tr_y,mdl)

% results with spline.p=0
% mdl performance (tr_perf) should be approx:
%       r2 = .77; MdAE = 6.40

%% Test

% apply model from training data to test data
% mdl.pred here is y_hat
fit     = prism_test(te_X,mdl);
% measure model performance, i.e., the whole point of this
te_perf = prism_eval(te_y,fit)

% fit performance (te_perf) should be approx:
%       r2 = .78; MdAE = 7.75

