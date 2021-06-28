%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script run functional connectivity analysis on time series of one
% subject. Estimates mutual information, then pairwise conditional 
% Granger causality (GC), then spectral GC.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise parameters

input_parameters;
%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'results');
fname = 'condition_ts_visual.mat';
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);
sub_id = time_series.sub_id;
fs = time_series.sfreq;
ts_type = time_series.ts_type;

fname = [sub_id '_' fname];
fpath = fullfile(datadir, fname);
save(fpath, 'time_series');
disp(sub_id);

%% Detrend

for i=1:ncat
    [X(:,:,:,i),~,~,~] = mvdetrend(X(:,:,:,i),pdeg,x);
    X(:,:,:,i) = demean(X(:,:,:,i),normalise);
end
%% Estimate model order parameters

for i=1:ncat
    [moaic(i),mobic(i),mohqc(i),molrt(i)] = tsdata_to_varmo(X(:,:,:,i), ... 
        momax,regmode,alpha,pacf,plotm,verb);
end

%% MI estimation
MI = zeros(nchan, nchan, ncat);
sig_MI = zeros(nchan, nchan, ncat);

for i=1:ncat
    [MI(:,:,i), sig_MI(:,:,i)] = ts_to_MI(X(:,:,:,i), 'q', q, 'mhtc', mhtc, 'alpha', alpha);
end
%% GC estimation

F = zeros(nchan, nchan, ncat);
sig_GC = zeros(nchan, nchan, ncat);

for i=1:ncat
    [F(:,:,i), sig_GC(:,:,i)] = ts_to_var_pcgc(X(:,:,:,i),'morder', mohqc(i),...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Save file

fname = [sub_id '_FC.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig_GC', 'MI', 'sig_MI')

%% Spectral GC estimation

for i=1:ncat
    f(:,:,:,i) = ts_to_var_spcgc(X(:,:,:,i), 'regmode',regmode, 'morder',mohqc(i),...
        'fres',fres, 'fs', fs);
end
%% Save file

fname = [sub_id '_spectral_GC.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'f')