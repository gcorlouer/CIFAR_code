%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Face'; end % 'Rest', 'Face', 'Place'
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
category = category(:,1);

% drop channel 5: 

X(5,:,:) = [];
%% Modeling

% VAR model 

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, 'multitrial', multitrial);


% SS model


[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
 

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

plot_pcgc(F, chan_type')
title('PWCGC (SS estimated)')



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