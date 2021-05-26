%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script estimate VAR model order from input time series along sliding
% window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input data parameters
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('momax', 'var') momax = 20; end
if ~exist('regmode', 'var') regmode = 'OLS'; end

alpha = [];
pacf = true;
plotm = 1;
verb = 0;

%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_continuous_sliding_ts.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, nwin, ncat] = size(X);

%% Estimate model order parameters from sliding window

for i=1:nwin
    for j=1:ncat
        [moaic(i,j),mobic(i,j),mohqc(i,j),molrt(i,j)] = tsdata_to_varmo(X(:,:,i,j),...
            momax,regmode,alpha,pacf,plotm,verb);
    end
end
