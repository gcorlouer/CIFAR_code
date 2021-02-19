%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Place'; end %  'Rest', 'Face' or 'Place'
if ~exist('step_window','var') step_window = 10; end 
if ~exist('window_size','var') window_size = 60; end

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 1; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('regmode', 'var') regmode = 'LWR'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end %  

chan_type = ['F','P','B'];

%% Import preprocessed data

[X, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;
ts = dataset.ts; 

[nchans, nobs, ntrials] = size(X);

% Simulation parameters
tsdim = 18; morder = 5; specrad = 0.98; ntrials = 28; nobs = 350;

% Sliding window 
if ~exist('step_window','var') step_window = 10; end 
if ~exist('window_size','var') window_size = 120; end


%% Simulate data

[X, var_coef, corr_res, connectivity_matrix] = var_sim(tsdim, ... 
    'morder', morder, 'specrad', specrad, 'nobs', nobs, 'ntrials', ntrials);


% % Pick channels 
% 
% picks = [1,2,6,7,8,9];
% category = category(picks);
% X = X(picks,:,:);
% Slide window 

X_win = slide_window(X, 'step_window',step_window, 'window_size', window_size);

[nchans, nobs, ntrials,nwin] = size(X_win);

%% Modeling whole epoched data

% VAR model 
tic
[VARmodel, VARmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc

% SS model

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc

%% Pairwise conditional GC 

F = ss_to_pwcgc(SSmodel.A, ... 
        SSmodel.C, SSmodel.K, SSmodel.V);

%% 

dclags = decorrlags(SSmodel.rhoa,nobs,alpha);
[F_perm,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,SSmodel.pf,SSmodel.mosvc,nperms,dclags);
sig = significance(pval,alpha,mhtc);


%% Plot mvgc 
subplot(2,2,1)
plot_pcgc(connectivity_matrix, chan_type')
title('PWCGC (SS estimated)')
subplot(2,2,2)
plot_pcgc(F, chan_type')
title('PWCGC (SS estimated)')
subplot(2,2,3)
plot_pcgc(sig, chan_type')
title('PWCGC (SS estimated)')
subplot(2,2,4)
plot_pcgc(F_perm, chan_type')
title('PWCGC (SS estimated)')
