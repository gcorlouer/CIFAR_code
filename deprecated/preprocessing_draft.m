%% Preprocess data with noisetool

% Parameters

subject = 'AnRa';
task = 'rest_baseline_1';
ext = '_bad_chans_removed.mat';
BP = false;
fs = 500;

% Preprocessing parameters


w = [];
basis = 'sinusoids';
thresh = 5;
niter = 3;

%% Load data 

datadir = cf_datadir('subject', subject);
[fname, dataset] = CIFAR_filename('subject', subject, 'task',task, ... 
    'ext', ext, 'BP',BP);
fpath = fullfile(datadir, fname);

data = load(fpath);

X = data.time_series;

[nchans, nobs] = size(X);

%% Detrend

x = X';
y = x;
deg_max = 5;
for i=1:deg_max
    order=i;
    [y,w,r]=nt_detrend(y,order,w,basis,thresh,niter);
end


%% Outlier removals 
w = [];
[w,y]=nt_outliers(y,w,thresh,niter);
nsample = nchans*nobs;
noutl = nsample-sum(w, 'all');
outlier_fraction = noutl/nsample*100;
disp(outlier_fraction)

%% Rereference by weighted mean

[y,mn]=nt_rereference(y,w);

%% Demean

[y,mn]=nt_demean(y,w);

%% Save file

X_p = y';

ext2save = '_preprocessed.mat';
fname2save = [dataset,ext2save];
fpath2save = fullfile(datadir, fname2save);
save(fpath2save, 'X_p')

%% Plot psd
% X_p = y';
% [S,f,nwobs,nobs,nwins] = tsdata_to_cpsd(X_p,fs,[],[],[],true);
% plot_autocpsd(S,f,fs,nchans);
%% 
subject = 'DiAs';
task = 'stimuli_1';
deg_max = 2;

preprocessed_signal = preprocessing('subject', subject, 'task', task, 'deg_max', deg_max);