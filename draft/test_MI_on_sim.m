tsdim = 6;
morder = 5;
specrad = 0.98;
nobs = 2000;
q = 0;
alpha = 0.05;
mhtc = 'FDRD';

%% Simulate data

[X, var_coef, corr_res, connectivity_matrix] = var_simulation(tsdim, ...
    'morder', morder, 'specrad', specrad, 'nobs', nobs);
[n, m, N] = size(X);
%% Estimate mutual information

V = tsdata_to_autocov(X,q);
[I,stats] = cov_to_pwcmi(V,m,N);
pval = stats.LR.pval;
sig = significance(pval,alpha,mhtc);
R = partialcorr(transpose(X)); % compare with partial corrleation (should be similar)
%%
category = 1:n;
Imax = max(I,[], 'all');
Rmax = max(R,[], 'all');
clims = [0 Imax];
subplot(2,2,1)
plot_pcgc(I, clims, category)
subplot(2,2,2)
plot_pcgc(R, [0 Rmax], category)
subplot(2,2,3)
plot_pcgc(sig, [0 1], category)
subplot(2,2,4)
plot_pcgc(connectivity_matrix, [0 1], category)
