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

%% Loading data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

fn = fieldnames(time_series);

X = time_series.(fn{ncat});

channel_to_population = time_series.channel_to_population;
%% Detrending

X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% VAR analysis

[F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);

TE = GC_to_TE(F, fs);

%% Plot result for functional classification

TE_max = max(TE, [],'all');
clims = [0 TE_max];
plot_title = ['Transfer entropy ', fn{ncat}];  
subplot(1,2,1)
plot_pcgc(TE, clims, channel_to_population)
title(plot_title)
subplot(1,2,2)
plot_pcgc(sig, [0 1], channel_to_population)
title('LR test')


%% Plot result for anatomical classification
% 
% clims = [0 0.6];
% DK = time_series.DK;
% DK = DK(:,8:10);
% plot_title = ['Transfer entropy ', fn{ncat}];  
% subplot(1,2,1)
% plot_pcgc(TE, clims, DK)
% title(plot_title)
% subplot(1,2,2)
% plot_pcgc(sig, [0 1], DK)
% title('LR test')

%% Save figure

% fig_dir = fullfile('~', 'projects', 'CIFAR', 'figures');
% fname = ['Transfer_entropy_', fn{ncat}, '.png'];
% fpath = fullfile(fig_dir, fname);
% saveas(gcf,fpath)

%% SS model analysis
% 
% [F, SSmodel, SSmoest, sig] = pwcgc_from_SSmodel(X, 'momax', momax, 'mosel', mosel, ... 
%     'multitrial', multitrial, 'moregmode', regmode);
% 
% TE = GC_to_TE(F, fs);
