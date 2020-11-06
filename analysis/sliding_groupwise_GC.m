%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Place'; end %  'Rest', 'Face' or 'Place'
if ~exist('step_window','var') step_window = 10; end 
if ~exist('window_size','var') window_size = 120; end

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


%%  Sliding window
    
X_win = slide_window(X, 'step_window',step_window, 'window_size', window_size);

[nchans, nobs, ntrials,nwin] = size(X_win);

%% VAR and State space modeling

[VARmodel, moest] = VARmodeling_sliding(X_win,'momax', momax, 'mosel', mosel); 

[SSmodel, moest] = SSmodeling_sliding(X_win,'momax', momax, 'mosel', mosel);

%% Groupwise GC effect size

F = sliding_ss_to_mvgc(SSmodel, category, chan_type);

%% Plot result

fs = 250;
ncat = size(chan_type,2);
time_step = step_window/fs;
duration = time_step*(nwin-1);

time = 0:time_step:duration;
for i=1:ncat
    for j = 1:ncat 
        if i==j
            continue
        else
            plot(time, squeeze(F(i,j,:)), 'DisplayName', sprintf('%c to %c ', chan_type(j), chan_type(i)))
            xlabel('Time')
            ylabel('Groupwise GC')
            hold on
        end
    end
end
legend('show')
