% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('cat','var') state = 'Rest'; end %  'Rest', 'Face' or 'Place'
if ~exist('step_window','var') step_window = 10; end 
if ~exist('window_size','var') window_size = 60; end

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

%%

X = slide_window(X, 'step_window', step_window, 'window_size', window_size);

%% VAR and State space modeling

[VARmodel, moest] = VARmodeling_sliding(X,'momax', momax, 'mosel', mosel); 

[SSmodel, moest] = SSmodeling_sliding(X,'momax', momax, 'mosel', mosel);

%% Sliding GC

F = sliding_ss_to_pwcgc(SSmodel, nchans);
F(isnan(F)) = 0;
%% Plot GC
nwin = size(F,3);
fs = 500;
time_step = step_window/fs;
duration = time_step*(nwin-1);
time = 0:time_step:duration;
for i=1:2
    for j=1:2
        if i==j
            continue 
        else
        plot(time, squeeze(F(i,j,:)), 'DisplayName', sprintf('%i to %i ', j, i))
        xlabel('Time (s)')
        ylabel('Pariwise GC')
        hold on
        plot(time, squeeze(F(i,j,:)), 'DisplayName', sprintf('%i to %i ', j, i))
        end
    end
end
legend('show')
title(['Pairwise conditional GC ', state,  ' presentation']);

