%% Test trials variability
% Main observation is that it totally explode with real HFB data this is
% true with 125 observations per trials which is not much.
% Can try upsampling, maybe will work better with more observation (but I 
% doubt it)
%% Load data

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);

%%

clear moaic mobic mohqc molrt
for j=1:ntrials
    for i=1:ncat
        [moaic(j,i),mobic(j,i),mohqc(j,i),molrt(j,i)] = tsdata_to_varmo(X(:,:,j,i), ... 
            momax,regmode,alpha,pacf,plotm,verb);
    end
end

%%
clear VAR
morder = 9;
for j=1:ncat
    for i=1:ntrials
        VAR(i,j) = ts_to_var_parameters(X(:,:,i,j), 'morder', morder, 'regmode', regmode);
    end 
end 