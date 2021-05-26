%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script run spectral GC analysis on time series of one
% subject. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('moregmode', 'var') regmode = 'OLS'; end % OLS or LWR
if ~exist('morder', 'var')    morder = 5; end % Model order

% Spectral parameters

fres = 1024;


%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
fs = time_series.sfreq;
[nchan, nobs, ntrial, ncat] = size(X);

%%

for i=1:ncat
    f(:,:,:,i) = ts_to_var_spcgc(X(:,:,:,i), 'regmode',regmode, 'morder',morder,...
        'fres',fres, 'fs', fs);
end
%% Save file

fname = [subject 'spectral_GC.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'f')