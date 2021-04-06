% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('moregmode', 'var') regmode = 'OLS'; end % OLS or LWR
if ~exist('morder', 'var')    morder = 5; end % Model order

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple testing correction
if ~exist('LR', 'var') LR = true; end % If false F test

%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);

%% GC estimation

F = zeros(nchan, nchan, ncat);
sig = zeros(nchan, nchan, ncat);

for i=1:ncat
    [F(:,:,i), sig(:,:,i)] = ts_to_var_pcgc(X(:,:,:,i),'morder', morder,...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Save file

fname = [subject 'pcgc.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig')