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
%%
dampen = 0.5;
tsdim = 3; nobs = 250; specrad = 0.96; morder = 5; ntrials = 56;

[X, var_coef, corr_res, connectivity_matrix] = var_simulation(tsdim, ... 
    'morder', morder, 'specrad', specrad, 'ntrials', ntrials, 'nobs', nobs);
X = dampen*X;
[nchan, nobs, ntrials] = size(X);

%% Load trend

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_trend.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

trend = time_series.data;
time = time_series.time;
[nchan, nobs] = size(trend);

Y = zeros(nchan, nobs, ntrials);
% Created trended data:
for i=1:ntrials
    Y(:,:,i) = X(:,:,i) + trend(:,:);
end
%% Add a linear trend
alpha = 10;
trend = alpha*time;
Y = X + trend;
%% Check trend

plot(time, X(2,:,1))
hold on
plot(time, Y(2,:,1))
%% GC untrend

[F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, 'momax', momax, 'mosel', mosel, ... 
        'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);
TE = GC_to_TE(F, fs);

%% GC trend

[F_trend, VARmodel_trend, VARmoest_trend, sig_trend] = pwcgc_from_VARmodel(trend, 'momax', momax, 'mosel', mosel, ... 
        'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);
TE_trend = GC_to_TE(F_trend, fs);

%% Plot result

channel_to_population = [];
TE_max = max(TE, [],'all');
TE_trend_max = max(TE_trend, [],'all');
clims = [0 TE_max];
plot_title = ['Transfer entropy no trend'];  
subplot(2,3,1)
plot_pcgc(TE, clims, channel_to_population)
title(plot_title)
subplot(2,3,2)
plot_pcgc(sig, [0 1], channel_to_population)
title('LR test')
subplot(2,3,3)
plot_pcgc(connectivity_matrix, [0 1], channel_to_population)
clims = [0 TE_trend_max];
plot_title = ['Transfer entropy  trend'];  
subplot(2,3,4)
plot_pcgc(TE_trend, clims, channel_to_population)
title(plot_title)
subplot(2,3,5)
plot_pcgc(sig_trend, [0 1], channel_to_population)
title('LR test')
subplot(2,3,6)
plot_pcgc(connectivity_matrix, [0 1], channel_to_population)

