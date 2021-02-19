% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('fs','var') fs = 250; end 
if ~exist('ncat','var') ncat = 12; end % 11: rest, 12: face, 13: place

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

% Temporal window in seconds

if ~exist('tmin', 'var') tmin = 0.3; end
if ~exist('tmax', 'var') tmax = 1; end
if ~exist('t_0', 'var') t_0 = -0.050; end

%% Loading data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_LFP_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);
time = time_series.time;

fn = fieldnames(time_series);

X = time_series.(fn{ncat});

%% Crop signal

[X, time] = crop_signal(X, time, 'tmin', tmin, 'tmax', tmax, 'fs', fs, 't_0', t_0);

%% Detrending

X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% VAR analysis

[F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);

TE = GC_to_TE(F, fs);

%% Plot result for functional classification

DK = time_series.DK;
DK = DK(:,8:23);
TE_max = max(TE, [],'all');
clims = [0 TE_max];
plot_title = ['Transfer entropy ', fn{ncat}];  
subplot(1,2,1)
plot_pcgc(TE, clims, population)
title(plot_title)
subplot(1,2,2)
plot_pcgc(sig, [0 1], population)
title('LR test')


%% SS model analysis
% 
% [F, SSmodel, SSmoest, sig] = pwcgc_from_SSmodel(X, 'momax', momax, 'mosel', mosel, ... 
%     'multitrial', multitrial, 'moregmode', regmode);
% 
% TE = GC_to_TE(F, fs);
