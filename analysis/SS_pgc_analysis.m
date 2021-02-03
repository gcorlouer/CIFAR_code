% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('fs','var') fs = 250; end 
if ~exist('ncat','var') ncat = 2; end 

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 20; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % 

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

fn = fieldnames(time_series);

X = time_series.(fn{ncat});
%X = X(:, srange, :);
X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% SS analysis

[F, SSmodel, SSmoest, sig] = pwcgc_from_SSmodel(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'nperms', nperms);

TE = GC_to_TE(F, fs);
%% Plot result 

clims = [0 0.5];
population = {'V1', 'Face'};
plot_title = ['Transfer entropy ', fn{ncat}];  
subplot(1,2,1)
plot_pcgc(TE, clims, population')
title(plot_title)
subplot(1,2,2)
plot_pcgc(sig, [0 1], population')
title('Stat test')

%% Save figure

% fig_dir = fullfile('~', 'projects', 'CIFAR', 'figures');
% fname = ['SS_transfer_entropy_', fn{ncat}, '.png'];
% fpath = fullfile(fig_dir, fname);
% saveas(gcf,fpath)

%% SS model analysis
% 
% [F, SSmodel, SSmoest, sig] = pwcgc_from_SSmodel(X, 'momax', momax, 'mosel', mosel, ... 
%     'multitrial', multitrial, 'moregmode', regmode);
% 
% TE = GC_to_TE(F, fs);
