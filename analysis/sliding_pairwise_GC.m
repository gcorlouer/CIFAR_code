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

%%  Sliding window
    
X_win = slide_window(X, 'step_window',step_window, 'window_size', window_size);

[nchans, nobs, ntrials,nwin] = size(X_win);

%% VAR and State space modeling

[VARmodel, moest] = VARmodeling_sliding(X_win,'momax', momax, 'mosel', mosel); 

[SSmodel, moest] = SSmodeling_sliding(X_win,'momax', momax, 'mosel', mosel);

%% Sliding Pairwise GC effect size

F = sliding_ss_to_pwcgc(SSmodel, nchans);

%% Compute average pGC

ntype = size(chan_type,2);

mean_F = zeros(ntype,ntype,nwin);

for i=1:ntype
    for j=1:ntype
        icat = cat2icat(category, chan_type(i));
        jcat = cat2icat(category, chan_type(j));
        mean_F(i,j,:) = mean(F(icat,jcat,:), [1,2]);
    end
end

%% Plot result


% fs = 250;
% ncat = size(chan_type,2);
% time_step = step_window/fs;
% duration = time_step*(nwin-1);
% 
% time = 0:time_step:duration;
% for i=1:ncat
%     for j = 1:ncat 
%         if i==j
%             continue
%         else
%             plot(time, squeeze(mean_F(i,j,:)), 'DisplayName', sprintf('%c to %c ', chan_type(j), chan_type(i)))
%             xlabel('Time')
%             ylabel('Mean pariwise GC')
%             hold on
%         end
%     end
% end
% legend('show')
%%
fs = 250;
ncat = size(chan_type,2);
time_step = step_window/fs;
duration = time_step*(nwin-1);

for i=1:2
    plot(time, squeeze(mean_F(i,3,:)), 'DisplayName', sprintf('%c to %c ', chan_type(3), chan_type(i)))
    xlabel('Time from stimulus onset (s)')
    ylabel('Mean pariwise GC')
    hold on
    plot(time, squeeze(mean_F(3,i,:)), 'DisplayName', sprintf('%c to %c ', chan_type(i), chan_type(3)))
end
legend('show')
xline(0.1,'-','Stimulus onset')
title(['Groupwise conditional GC ', cat,  ' presentation']);
% Problem with stimulus onset becaus window is in fact modeling sighlty
% before and after stimulus presentation
