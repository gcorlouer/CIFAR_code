%% Parameters 

if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end
if ~exist('cat','var') cat = 'Face'; end % Presented category

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end
if ~exist('mosel', 'var') mosel = 4; end 

regmode = 'LWR';
alpha = 0.05;
mhtc = 'FDRD';


%% Import data

[X, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;

[nchans, nobs, ntrials] = size(X);
chan_type = ['F','P','B'];
iF = cat2icat(category, 'F');
iP = cat2icat(category, 'P');
iB = cat2icat(category, 'B');
%% Modeling

% VAR model 
tic
[VARmodel, VARmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc
% SS model

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

%% Groupwise GC

target_chan = iB;
source_chan = iF;
tic
[F, sig_p] = SSmodel_to_mvgc_permtest(X, SSmodel,target_chan, source_chan);
toc

%% Pairwise GC

tic
[F, sig_p] = SSmodel_to_pwcgc_permtest(X, SSmodel, 'alpha',alpha, 'nperms',nperms);
toc

%% Pairwise GC

sspf = 2*VARmoest(mosel);
ssmo = SSmoest(mosel);
dclags = decorrlags(SSmodel.rhoa,nobs,alpha);
nperms = 100; 
regmode = 'LWR';
alpha = 0.05;
mhtc = 'FDR'; 
ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
[F,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,sspf,ssmo,nperms,dclags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

sig_p  = significance(pval,alpha,mhtc);

%% Plot

pdata = {F, sig_p};

ptitle = {'PWCGC (SS estimated)','Permutation test'};

plot_gc(pdata,ptitle,[],[],[]);


%% Plot and compare quantities

% n = nchans ;
% subplot(1,2,1)
% colormap('hot');
% imagesc(F);
% axis('square');
% xlabel('from');
% ylabel('to');
% set(gca,'XTick',1:n);
% set(gca,'XTickLabel',1:n);
% set(gca,'YTick',1:n);
% set(gca,'YTickLabel',n:-1:1);
% colorbar
% 
% subplot(1,2,2)
% colormap('hot');
% imagesc(sig_p);
% axis('square');
% xlabel('from');
% ylabel('to');
% 
% set(gca,'XTick',1:n);
% set(gca,'XTickLabel',1:n);
% set(gca,'YTick',1:n);
% set(gca,'YTickLabel',n:-1:1);
% colorbar

%% Count significant GC connections 

nsig = count_significant_GC(sig_p, iB,iP);
    