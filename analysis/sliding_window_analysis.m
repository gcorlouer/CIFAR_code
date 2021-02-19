% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 15; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test

%% Loading data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_slided_category_visual_HFB.mat'];
fpath = fullfile(datadir, fname);
time_series = load(fpath);

X = double(time_series.data);
fs = double(time_series.sfreq);

[nchan, nobs, ntrial, nseg, ncat] = size(X);
%% Run GC analysis on sliding window for each category

F = zeros(nchan, nchan, nseg, ncat);
TE = zeros(nchan, nchan, nseg, ncat);

for c = 1:ncat
    for w = 1:nseg
        [F(:,:,w,c), VARmodel, VARmoest, sig(:,:, w,c)] = pwcgc_from_VARmodel(X(:,:,:,w,c), 'momax', momax, 'mosel', mosel, ... 
            'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);

        TE(:,:,w,c) = GC_to_TE(F(:,:,w,c), fs);
    end
end

%% Plot for fast check
cat = 2;
seg = 1;
channels = 1:nchan;

TE_max = max(TE(:,:,seg,cat), [],'all');
clims = [0 TE_max];
plot_title = ['Transfer entropy cat', num2str(cat)];  
subplot(1,2,1)
plot_pcgc(squeeze(TE(:,:,seg,cat)), clims, channels)
title(plot_title)
subplot(1,2,2)
plot_pcgc(squeeze(sig(:,:,seg,cat)), [0 1], channels)
title('LR test')

%% Detrend

% for i=1:ncat
%     for j=1:nseg
%         X(:,:,:,j,i) = detrend_HFB(X(:,:,:,j,i), 'deg_max', 2);
%     end
% end