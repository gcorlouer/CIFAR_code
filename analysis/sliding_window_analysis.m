% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('fs','var') fs = 100; end 
if ~exist('ncat','var') ncat = 11; end % 11: rest, 12: face, 13: place

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test

% Sliding window parameters
tmin = 0.075;
tmax = 0.350;
start = 0.100;
stop = 0.400;
window_size = 0.050;
tau = 0.010;

%% Loading data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

fn = fieldnames(time_series);

X = time_series.(fn{ncat});
time = time_series.time;

channel_to_population = time_series.channel_to_population;

%% Crop signal

[X, time] = crop_signal(X, time, 'tmin', tmin, 'tmax', tmax, 'fs', fs);
%% Detrend

X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% Create sliding window

sliding_ts = slide_window(X, 'start', start, 'stop', stop, 'window_size', ... 
    window_size,'tau', tau);

size(sliding_ts)

%% Run GC analysis on sliding window



