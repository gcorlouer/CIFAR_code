%% Load data
%% TODO : Indices compatibility for matlab and python 

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual_test.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);

%% 

anatomical_idx = time_series.ROI_indices;
functional_idx = time_series.functional_indices;
ROI_idx = functional_idx;
%%
fn = fieldnames(ROI_idx);
nROI = numel(fn);
F = zeros(nROI, nROI, ncat);
sig_GC = zeros(nROI, nROI, ncat);

for i=1:ncat
    [F(:,:,i), sig_GC(:,:,i)] = ts_to_var_mvgc(X(:,:,:,i), ROI_idx, 'morder', morder,...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end
