%% Parameters 

if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'rest_baseline_1'; end
if ~exist('montage','var') montage = 'raw_signal'; end
if ~exist('BP','var') BP = false'; end

%% Import data 
datadir = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets', montage);
[fname, dataset] = CIFAR_filename('subject', subject,'task', task,'BP', BP);
fpath = fullfile(datadir, fname);
EEG = pop_loadset(fname, datadir); 
%% 
fs = 500;
fline = 60/fs;
nremove = 4;

X = EEG.data;
x = transpose(X);
y = nt_zapline(x,fline,nremove);
Y = transpose(y);
%% Plot cpsd
nchans = size(X,1);
%[S,f,nwobs,nobs,nwins] = tsdata_to_cpsd(X,fs,[],[],[],true);
[S_filt,f,nwobs,nobs,nwins] = tsdata_to_cpsd(Y,fs,[],[],[],true);
plot_autocpsd(S,f,fs,nchans);
loglog(f,S_filt)
%% Save data 
ext = '_lnrmv.mat';
fpath = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets');
fpath = fullfile(fpath, 'preproc');
[fname, dataset] = CIFAR_filename('subject', subject,'task', task,'BP', BP, 'ext', ext);
EEG.data = Y;
EEG = pop_saveset(EEG, 'filename', fname, 'filepath', fpath, 'savemode', 'onefile');