%% Load data
input_parameters;
replacement = true; B = 1000;

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_ts_visual.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, nobs, ntrial, ncat] = size(X);
K = ntrial;
%% GC estimation

F = zeros(nchan, nchan, ncat);
sig_GC = zeros(nchan, nchan, ncat);

for i=1:ncat
    [F(:,:,i), sig_GC(:,:,i)] = ts_to_var_pcgc(X(:,:,:,i),'morder', morder,...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Bootstrapp estimation
F_B = zeros(nchan,nchan, B, ncat);
% Sample K trials with replacement
for ib=1:B
    sampled_trials = randsample(ntrial, K, replacement);
    X_b = zeros(nchan, nobs, K, ncat);
    for i=1:K
        X_b(:,:,i,:) = X(:,:,sampled_trials(i),:);
    end
    %% Estimate VAR model order and GC 
    for i_cdt=1:ncat
        [~,~,mohqc(i_cdt),~] = tsdata_to_varmo(X_b(:,:,:,i_cdt), ... 
                momax,regmode,alpha,pacf,plotm,verb);
        morder = mohqc(i_cdt);

        [F_B(:,:,ib,i_cdt), ~] = ts_to_var_pcgc(X_b(:,:,:,i_cdt),'morder', morder,...
                'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
    end
end