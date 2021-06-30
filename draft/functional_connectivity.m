%% Parameters 

if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end
if ~exist('cat','var') cat = 'Face'; end % Presented category

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end


%% Import data

[X, dataset] = import_preproc_data();

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;

nchans = size(X,1);
%% Functional connectivity TO REDO

group = {1:10};
connectivity = 'intra'; 

[MI, stats] = multi_info(X, 'connectivity', connectivity, 'multitrial', multitrial, 'group', group);

%% Re Functional connectivity

[n, m, N] = size(X);

% pairwise conditional MI :

lag = 0;
V = tsdata_to_autocov(X,lag);
[MI, stats] = cov_to_pwcmi(V,m,N);

pval = stats.LR.pval;
alpha = 0.05;
correction = 'HOLM';
sig = significance(pval,alpha,correction);

% Groupwise conditional MI

%% Interpret FC


subplot(1,2,1)
heatmap(sig, 'XData', ch_names, 'YData', ch_names)
subplot(1,2,2)
heatmap(sig, 'XData', ch_names, 'YData', ch_names)

sig_tril = tril(sig);
% colormap;
imagesc(sig_tril,[0 1]);
colorbar;
axis('square');
set(gca,'XTick', 1:n);
set(gca,'XTickLabel',category);
xtickangle(90)
set(gca,'YTick',1:n);
set(gca,'YTickLabel',category);
title('lol')
