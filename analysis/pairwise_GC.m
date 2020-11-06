%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Place'; end %  'Rest', 'Face' or 'Place'

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 1; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('regmode', 'var') regmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end %  

chan_type = ['F','P','B'];
ntype = size(chan_type,2);
%% Import preprocessed data

[X, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
category = dataset.category;

[nchans, nobs, ntrials] = size(X);

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

% F_max = max(F,[],'all');

% F = F/F_max;

%% Significance

% dclags = decorrlags(SSmodel.rhoa,nobs,alpha);
% [F_perm,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,SSmodel.pf,SSmodel.mosvc,nperms,dclags);
% sig = significance(pval,alpha,mhtc);


%% Compute average pGC

mean_F = zeros(ntype,ntype);

for i=1:ntype
    for j=1:ntype
        icat = cat2icat(category, chan_type(i));
        jcat = cat2icat(category, chan_type(j));
        mean_F(i,j) = mean(F(icat,jcat), [1,2]);
    end
end

%% 

plot_pcgc(mean_F, chan_type')
title('PWCGC (SS estimated)')

%% Plot mvgc

visual_type = category(:,1);
subplot(1,2,1)
plot_pcgc(F, visual_type)
title('PWCGC (SS estimated)')
subplot(1,2,2)
plot_pcgc(sig, visual_type)
title('PWCGC significance (SS estimated)')
