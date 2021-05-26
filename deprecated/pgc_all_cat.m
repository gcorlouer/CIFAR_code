% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 4; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 20; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);

%%
% for icat=1:ncat
%     X(:,:,:,icat) = detrend_HFB(X(:,:,:,icat), 'deg_max', 2);
% end

%% VAR analysis

F = zeros(nchan, nchan, ncat);
sig = zeros(nchan, nchan, ncat);

for i=1:ncat
    [F(:,:,i), VARmodel, VARmoest, sig(:,:,i)] = pwcgc_from_VARmodel(X(:,:,:,i), 'momax', momax, 'mosel', mosel, ... 
        'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);
end

%% Save file

fname = [subject 'pcgc.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig')