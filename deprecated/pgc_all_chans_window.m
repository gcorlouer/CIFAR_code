% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 20; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_HFB_win_all_chan.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs] = size(X);

%% VAR analysis

F = zeros(nchan, nchan);
sig = zeros(nchan, nchan);


[F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, 'momax', momax, 'mosel', mosel, ... 
        'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);


%% Save file

fname = [subject 'pcgc.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig')