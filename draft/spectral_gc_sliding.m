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

if ~exist('fres', 'var') fres = 1024; end

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_sliding.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
time = time_series.time;
sfreq = time_series.sfreq;
[nchan, nobs, ntrial, nwin, ncat] = size(X);

%% Spectral GC analysis

F = zeros(nchan, nchan, nwin, ncat);
sig = zeros(nchan, nchan, nwin, ncat);
f = zeros(nchan, nchan, fres, nwin, ncat);

for i=1:ncat
    for j=1:nwin
        [F(:,:,j,i), VARmodel, VARmoest, sig(:,:,j,i)] = pwcgc_from_VARmodel(X(:,:,:,j,i), 'momax', momax, 'mosel', mosel, ... 
            'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);
        f(:,:,:,j,i) = var_to_spwcgc(VARmodel.A,VARmodel.V, fres-1);
        f(isnan(f)) = 0;
    end
end

%% Save file

fname = [subject 'sliding_sgc.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'f', 'sig','time', 'sfreq')
