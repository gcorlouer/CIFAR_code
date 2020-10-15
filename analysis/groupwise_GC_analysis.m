%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Face'; end % Presented category
if ~exist('step_window','var') step_window = 10; end % Presented category
if ~exist('window_size','var') window_size = 120; end % Presented category

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 4; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('regmode', 'var') regmode = 'LWR'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 

% Select source and target chan
source_chan = 'B';
target_chan = 'F';

% BEWARE: Make sure target and source channels are well defined in the
% SSmodel_to_mvgc_permtest() function with respect to Lionel funciton.
%% Import preprocessed data

[X, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;
ts = dataset.ts; 

[nchans, nobs, ntrials] = size(X);

% Return Face, place, and Bicategory channel indices
chan_type = ['F','P','B'];
iF = cat2icat(category, 'F');
iP = cat2icat(category, 'P');
iB = cat2icat(category, 'B');
category = category(:,1);

X_win = slide_window(X, 'step_window',step_window, 'window_size', window_size);

[nchans, nobs, ntrials,nwin] = size(X_win);

%% Detrend 

clear Y;

pdeg = 10;

for w=1:nwin
    [Y(:,:,:,w),P,p,x] = mvdetrend(X_win(:,:,:,w),pdeg);
end

%% 

[VARmodel, moest] = VARmodeling_sliding(X_win,'momax', momax, 'mosel', mosel); 

[SSmodel, moest] = SSmodeling_sliding(X_win,'momax', momax, 'mosel', mosel);

%% Modeling

% % VAR model 
% tic
% [VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, 'multitrial', multitrial);
% toc
% 
% % SS model
% 
% tic
% [SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
% toc   

%% Groupwise GC effect size

F = zeros(ncat,ncat,nwin);
for i=1:size(chan_type,2)
    for j=1:size(chan_type,2)
        for w=1:nwin
            if i==j
                F(i,j,w)=0;
            else
                itarget_chan =  cat2icat(category, chan_type(i));
                isource_chan =  cat2icat(category, chan_type(j));
                F(i, j, w) = ss_to_mvgc(SSmodel(w).A, ... 
                    SSmodel(w).C, SSmodel(w).K, SSmodel(w).V, ... 
        isource_chan, itarget_chan);
            end
        end
     end
end


%% Groupwise conditional GC

[F_gp, sig_gp] = SSmodel_to_mvgc_permtest(X_win, SSmodel, itarget_chan, isource_chan);

%%
[F_gp, sig_gp] = SSmodel_to_ggc(X, SSmodel, multitrial, category, ... 
    'alpha', alpha, 'nperms', nperms, 'mhtc', mhtc);

ncat = size(chan_type,2);

F_gp = zeros(ncat,ncat,nwin);
sig_gp = zeros(ncat,ncat,nwin);

for i=1:size(chan_type,2)
    for j=1:size(chan_type,2)
        for nwin=1:ntrials
            itarget_chan =  cat2icat(category, chan_type(i));
            isource_chan =  cat2icat(category, chan_type(j));
            if i==j
                [F_gp(i,j,nwin), sig_gp(i,j,nwin)] = deal(0,0);
            else
                tic
                [F_gp(i,j,nwin), sig_gp(i,j,nwin)] = SSmodel_to_mvgc_permtest(X ... 
                    SSmodel(nwin), itarget_chan, isource_chan);
                toc
            end
        end
    end
end

%% Multitrial

chan_type = ['F','P','B'];
ncat = size(chan_type,2);
ntrials = size(X,3);

F_gp = zeros(ncat,ncat);
sig_gp = zeros(ncat,ncat);

for i=1:size(chan_type,2)
    for j=1:size(chan_type,2)
        itarget_chan =  cat2icat(category, chan_type(i));
        isource_chan =  cat2icat(category, chan_type(j));
        if i==j
            [F_gp(i,j), sig_gp(i,j)] = deal(0,0);
        else
            tic
            [F_gp(i,j), sig_gp(i,j)] = SSmodel_to_mvgc_permtest(X, ... 
                SSmodel, itarget_chan, isource_chan);
            toc
        end
    end
end

%% Plot  mvgc
% 
% x = 1:1:ntrials;
% subplot(2,1,1)
% plot(x, F_gp)
% xlabel('trial')
% ylabel('GC')
% title('Groupwise GC')
% subplot(2,1,2)
% plot(x, sig_gp)
% xlabel('trial')
% ylabel('Significant GC')
% title('Significant groupwise GC')

%% Plot mvgc multitrial

subplot(1,2,1)
plot_pcgc(F_gp, chan_type')
title('PWCGC (SS estimated)')
subplot(1,2,2)
plot_pcgc(sig_gp, chan_type')
title('Permutation test')

%% Plot sliding window F

trial_axis = 1:1:ntrials;
for i=1:ncat
    for j=1:ncat
        plot(trial_axis, squeeze(F_gp(i,j,:)))
        hold on
    end
end
        
%% 

plot(trial_axis, squeeze(F_gp(3,1,:)))
hold on 
plot(trial_axis, squeeze(F_gp(3,2,:)))
%% Plot sig F,P,R

% subplot(2,2,1)
% plot_pcgc(sigp_Rest, category)
% title('GC Rest')
% subplot(2,2,2)
% plot_pcgc(sigp_Face, category)
% title('GC Face')
% subplot(2,2,3)
% plot_pcgc(sigp_Place, category)
% title('GC Place')