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

%% VAR and State space modeling on window

[VARmodel, moest] = VARmodeling_sliding(X_win,'momax', momax, 'mosel', mosel); 

[SSmodel, moest] = SSmodeling_sliding(X_win,'momax', momax, 'mosel', mosel);

%% Pairwise GC 

F = sliding_ss_to_pwcgc(SSmodel, nchans);

%% Plot 

fs = 250;
ncat = size(chan_type,2);
time_step = step_window/fs;
duration = time_step*(nwin-1);

time = 0:time_step:duration;

for i=1:npairs
    for j = 1:npairs 
        if i==j
            continue
        else
            plot(time, squeeze(F(pairs(i),pairs(j),:)), 'DisplayName', ... 
                sprintf('%c to %c ', category(pairs(i),1), category(pairs(j),1)))
            xlabel('Time (s)')
            ylabel('Pairwise GC')
            hold on
        end
    end
end

legend('show')
title(sprintf('Pairwise conditional GC on sliding window on %s time series', cat))

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
%% Plot mvgc 
subplot(1,2,1)
plot_pcgc(connectivity_matrix, chan_type')
title('PWCGC (SS estimated)')
subplot(1,2,2)
plot_pcgc(F, chan_type')
title('PWCGC (SS estimated)')



%% Groupwise GC effect size

F = sliding_ss_to_mvgc(SSmodel, category, chan_type);


%% Plot
fs = 250;
cat = category(:,1);
ncat = size(category,1);
time_step = step_window/fs;
duration = time_step*(nwin-1);

time = 0:time_step:duration;
for i=1:nchans
    for j = 1:nchans 
        if i==j
            continue
        else
            plot(time, squeeze(F(i,j,:)), 'DisplayName', sprintf('%c to %c ', cat(j), cat(i)))
            xlabel('Time')
            ylabel('Groupwise GC')
            hold on
        end
    end
end
legend('show')
%% Modeling whole epoched data

% VAR model 
tic
[VARmodel, VARmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc

% SS model

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

%% Multitrial

ncat = size(chan_type,2);

F = zeros(ncat,ncat);
sig = zeros(ncat,ncat);


for i=1:size(chan_type,2)
    for j=1:size(chan_type,2)
        itarget_chan =  cat2icat(category, chan_type(i));
        isource_chan =  cat2icat(category, chan_type(j));
        if i==j
            [F(i,j), sig(i,j)] = deal(0,0);
        else
            tic
            F(i,j) = ss_to_mvgc(SSmodel.A, ... 
                    SSmodel.C, SSmodel.K, SSmodel.V, ... 
        itarget_chan, isource_chan);
            toc
        end
    end
end


%% Plot mvgc 

plot_pcgc(connectivity_matrix, chan_type')
title('PWCGC (SS estimated)')

