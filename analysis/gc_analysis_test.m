% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('cat','var') state = 'Face'; end %  'Rest', 'Face' or 'Place'
if ~exist('cat','var') fs = 500; end %

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 4; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 30; end % Max model order 
if ~exist('regmode', 'var') regmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end %  

%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_', state, '_test.mat'];
fpath = fullfile(datadir, fname);

dataset = load(fpath);

X = dataset.data;

[nchans, nobs, ntrials] = size(X);

%% Detrend data 

X = detrend_HFB(X);

%% Compute TE

F = pairwise_conditional_GC(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', regmode);

TE = GC_to_TE(F, fs);

%% Plot result
population = {'Face', 'V1'};
clims = [0 0.4];
plot_pcgc(TE, clims, population')
