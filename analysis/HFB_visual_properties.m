% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('cat','var') state = 'Place'; end %  'Rest', 'Face' or 'Place'

%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_', state, '_test.mat'];
fpath = fullfile(datadir, fname);

dataset = load(fpath);

X = dataset.data;

[nchans, nobs, ntrials] = size(X);


%% Plot evok response

evok = mean(X,3);
leg = [];
dt = 1/500;
trange = [];

plot_tsdata(evok,leg,dt,trange)
ylabel('Amplitude (dB)')

%% Plot cpsd

fs = 500;
[nchans, nobs, ntrials] = size(X);
[S,f] = tsdata_to_cpsd(X,fs, [],[],[],true); 
plot_autocpsd(S,f,fs,nchans)

%% Detrend and demean HFN

X = detrend_HFB(X);

%% Plot evok response

evok = mean(X,3);
leg = [];
dt = 1/500;
trange = [];

plot_tsdata(evok,leg,dt,trange)
ylabel('Amplitude (dB)')

%% Check Gaussianity 

histogram(X)
y = reshape(X, [nchans, nobs*ntrials]);
skew = skewness(y, 1, 2);
k = kurtosis(y,1,2);
