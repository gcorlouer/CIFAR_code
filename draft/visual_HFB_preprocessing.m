% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
fs = 250;
%% Load data
datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);
fn = fieldnames(time_series);


%% Plot evok response

leg = [];
dt = 1/fs;
trange = [];
for i=1:3
    X = time_series.(fn{i+10});
    evok = mean(X,3);
    subplot(3,1,i)
    plot_tsdata(evok,leg,dt,trange)
    xlabel('Time (s)')
    ylabel('dB')
    %titletext = ['HFB evoked response ', fn{i}, ' presentation'];
    %title(titletext);
    hold on
end
%% Plot cpsd

i = 1;
X = time_series.(fn{i+10});
[nchans, nobs, ntrials] = size(X);
[S,f] = tsdata_to_cpsd(X,fs, [],[],[],true); 
plot_autocpsd(S,f,fs)

%% Detrend and demean HFN
deg_max = 2;
[n, m, N] = size(X);
for i=1:3
    X = time_series.(fn{i+10});
    X = detrend_HFB(X, 'deg_max', deg_max);
    evok = mean(X,3); % average over trials and channels for better visibility
    % N = n*N;
    % SE = std(X,[1 3])/sqrt(N);
    subplot(3,1,i)
    plot_tsdata(evok,leg,dt,trange)
    xlabel('Time (s)')
    ylabel('dB')
    %titletext = ['HFB evoked response ', fn{i}, ' presentation'];
    %title(titletext);
    hold on
end

%% Check Gaussianity 
for i=1:3
    X = time_series.(fn{i+10});
    [nchans, nobs, ntrials] = size(X);
    X = detrend_HFB(X);
    subplot(3,1,i)
    histogram(X)
    hold on 
    y = reshape(X, [1 nchans*nobs*ntrials]);
    skew = skewness(y);
    k = kurtosis(y);
    fprintf(['Skewness is %d for ', fn{i}, '\n'], skew)
    fprintf(['kurtosis is %d for ', fn{i}, '\n'], k)
    
end