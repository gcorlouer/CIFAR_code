%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Face'; end % Presented category

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 4; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('regmode', 'var') regmode = 'LWR'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('npersm', 'var') nperms = 10; end % 

%% Import preprocessed data

[X, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;

[nchans, nobs, ntrials] = size(X);

% Return Face, place, and Bicategory channel indices
chan_type = ['F','P','B'];
iF = cat2icat(category, 'F');
iP = cat2icat(category, 'P');
iB = cat2icat(category, 'B');
category = category(:,1);
%% Modeling

% VAR model 
tic
[VARmodel, VARmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc

% SS model

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

%% Pairwise conditional GC

tic
[F, sig_p] = SSmodel_to_pwcgc_permtest(X, SSmodel, 'alpha',alpha, 'nperms',nperms);
toc

%% Plot and compare pcgc

subplot(1,2,1)
plot_pcgc(F, category)
title('PWCGC (SS estimated)')
subplot(1,2,2)
plot_pcgc(sig_p, category)
title('Permutation test')

%% Count significant pairwise GC connections 


% nsig = count_significant_GC(sig_p, iB,iP);
% fprintf('%d significant GC from B to P.\n', nsig);
% nsig = count_significant_GC(sig_p, iB,iF);
% fprintf('%d significant GC from B to F.\n', nsig);
% nsig = count_significant_GC(sig_p, iF,iB);
% fprintf('%d significant GC from F to B.\n', nsig);
% nsig = count_significant_GC(sig_p, iP,iB);
% fprintf('%d significant GC from P to B.\n', nsig);
% nsig = count_significant_GC(sig_p, iP,iF);
% fprintf('%d significant GC from P to F.\n', nsig);
% nsig = count_significant_GC(sig_p, iF,iP);
% fprintf('%d significant GC from F to P.\n', nsig);

