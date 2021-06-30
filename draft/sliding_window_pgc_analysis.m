%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script run functional connectivity analysis on time series of one
% subject. Estimates mutual information and then pairwise conditional 
% Granger causality (GC).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Mutual information
if ~exist('q', 'var')    q = 0; end % Covariance lag

% Modeling
if ~exist('moregmode', 'var') regmode = 'OLS'; end % OLS or LWR
if ~exist('morder', 'var')    morder = 8; end % Model order

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple testing correction
if ~exist('LR', 'var') LR = true; end % If false F test

%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_continuous_sliding_ts.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
time = time_series.time;
sfreq = time_series.sfreq;
[nchan, nobs, nwin, ncat] = size(X);

%% MI estimation
MI = zeros(nchan, nchan, nwin, ncat);
sig_MI = zeros(nchan, nchan, nwin, ncat);

for i=1:nwin
    for j=1:ncat
        [MI(:,:,i,j), sig_MI(:,:,i,j)] = ts_to_MI(X(:,:,i,j), 'q', q,...
            'mhtc', mhtc, 'alpha', alpha);
    end
end
%% GC estimation

F = zeros(nchan, nchan, nwin, ncat);
sig_GC = zeros(nchan, nchan, nwin, ncat);

for i=1:nwin
    for j=1:ncat
        [F(:,:,i,j), sig_GC(:,:,i,j)] = ts_to_var_pcgc(X(:,:,i,j),'morder', morder,...
            'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
    end
end

%% Save file

fname = [subject '_pgc_sliding_continuous.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig_GC', 'MI', 'sig_MI', 'time', 'sfreq')