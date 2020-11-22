function preprocessed_signal = preprocessing(varargin)

defaultBP = false;
defaultSubject = 'AnRa';
defaultTask = 'rest_baseline_1';
defaultExt = '_lnrmv.set';

defaultThresh = 5;
defaultBasis = 'sinusoids';
defaultW = [];
defaultNiter = 3;
defaultDeg_max = 10;

p = inputParser;

addParameter(p, 'BP', defaultBP, @islogical);
addParameter(p, 'subject', defaultSubject, @isvector);
addParameter(p, 'task', defaultTask,@isvector);
addParameter(p, 'ext', defaultExt,@isvector);
addParameter(p, 'thresh' , defaultThresh,@isscalar);
addParameter(p, 'basis', defaultBasis,@isvector);
addParameter(p, 'w', defaultW);
addParameter(p, 'niter', defaultNiter);
addParameter(p, 'deg_max', defaultDeg_max);

parse(p, varargin{:});

BP = p.Results.BP;
subject = p.Results.subject;
task =  p.Results.task;
ext =  p.Results.ext;

thresh =  p.Results.thresh;
basis =  p.Results.basis;
w =  p.Results.w;
niter =  p.Results.niter;
deg_max =  p.Results.deg_max;

%% Load data 
datadir = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets', 'preproc');
[fname, dataset] = CIFAR_filename('subject', subject,'task', task,'BP', BP, 'ext', ext);
fpath = fullfile(datadir, fname);
EEG = pop_loadset(fname, datadir); 

X = EEG.data;

[nchans, nobs] = size(X);

%% Detrend

x = X';
y = x;

for i=1:deg_max
    order=i;
    [y,w,r]=nt_detrend(y,order,w,basis,thresh,niter);
end

%% Rereference by weighted mean

[y,mn]=nt_rereference(y,w);

%% Demean

[y,mn]=nt_demean(y,w);

nsample = nchans*nobs;
noutl = nsample-sum(w, 'all');
outlier_fraction = noutl/nsample*100;
fprintf('%f outlier removed', outlier_fraction)


X = y';

%% Save data 
ext = '_preprocessed.set';
fpath = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets');
fpath = fullfile(fpath, 'preproc');
[fname, dataset] = CIFAR_filename('subject', subject,'task', task,'BP', BP, 'ext', ext);
EEG.data = X;
EEG = pop_saveset(EEG, 'filename', fname, 'filepath', fpath, 'savemode', 'onefile');
end
