% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_HFB_all_chan.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

X = time_series.data;
[nchan, m, N, ncat] = size(X);
%%
q = 0;
V = zeros(nchan, nchan, ncat);
I = zeros(size(V)); 
sig = zeros(size(V));

for icat=1:ncat
    V(:,:,icat) = tsdata_to_autocov(X(:,:,:,icat),q);
    [I(:,:,icat),stats] = cov_to_pwcmi(V(:,:,icat),m,N);
    pval = stats.LR.pval;
    sig(:,:,icat) = significance(pval,alpha,mhtc);
end

%% Save file

fname = [subject 'MI.mat'];
fpath = fullfile(datadir, fname);

save(fpath, 'I', 'sig')
