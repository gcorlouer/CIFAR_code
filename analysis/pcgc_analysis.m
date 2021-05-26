%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script run functional connectivity analysis on time series of one
% subject. Estimates mutual information and then pairwise conditional 
% Granger causality (GC).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise parameters

input_parameters;
%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual_test.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);

%% MI estimation
MI = zeros(nchan, nchan, ncat);
sig_MI = zeros(nchan, nchan, ncat);

for i=1:ncat
    [MI(:,:,i), sig_MI(:,:,i)] = ts_to_MI(X(:,:,:,i), 'q', q, 'mhtc', mhtc, 'alpha', alpha);
end
%% GC estimation

F = zeros(nchan, nchan, ncat);
sig_GC = zeros(nchan, nchan, ncat);

for i=1:ncat
    [F(:,:,i), sig_GC(:,:,i)] = ts_to_var_pcgc(X(:,:,:,i),'morder', morder,...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Save file

fname = [subject 'FC.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig_GC', 'MI', 'sig_MI')