%% Parameters

% Simulation

tsdim = 8;
morder = 5;
nobs = 1000;
ntrials = 1;

% Estimation

mosel = 1;
multitrial = true;
regmode = 'OLS';

alpha = 0.05;
mhtc = 'FDR';
nperms =100; 


%% Analysis

% Simulate var

[tsdata, var_coef, corr_res, connectivity_matrix] = var_sim(tsdim, ... 
    'morder', morder, 'nobs', nobs);
X = tsdata;

%% VAR estimation 

% VAR model estimation

tic
[VARmodel, varmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** var_to_pwcgc... ');
[F,pval] = var_to_pwcgc(VARmodel.A, VARmodel.V, X, regmode);
ptoc;

% Significance test (F-test and likelihood ratio), adjusting for multiple hypotheses.

sigFT = significance(pval.FT,alpha,mhtc);
sigLR = significance(pval.LR,alpha,mhtc);

% Plot time-domain causal graph and significance.

pdata = {connectivity_matrix, F; sigFT, sigLR};
ptitle = {'PWCGC (actual)','PWCGC (estimated)'; 'F-test','LR test'};

plot_gc(pdata,ptitle,[],[],[]);
% [n, m, N] = size(X);
% 
% % pairwise conditional MI :
% 
% lag = 0;
% V = tsdata_to_autocov(X,lag);
% [MI, stats] = cov_to_pwcmi(V,m,N);
% 
% pval = stats.LR.pval;
% alpha = 0.05;
% correction = 'HOLM';
% sig = significance(pval,alpha,correction);
% 
% pdata = {connectivity_matrix, MI; sig, sigLR};
% 
% ptitle = {'PWCGC (actual)','MI (estimated)'; 'MI (sig)','LR test'};
% 
% plot_gc(pdata,ptitle,[],[],[]);

%% SS model estimation

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

F = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

%% Permutation test previous version

% morder = varmoest(mosel);
% ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
% FNULL = permtest_tsdata_to_pwcgc(X,morder,[],nperms);
% ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);
% 
% % (We should probably check for failed permutation estimates here.)
% 
% % Permutation test significance test (adjusting for multiple hypotheses).
% 
% pval_p = empirical_pval(F,FNULL);
% sig_p  = significance(pval_p,alpha,mhtc);
% 

%% Permutation test with rotation

sspf = 2*moest(mosel);
ssmo = SSmoest(mosel);
dclags = decorrlags(SSmodel.rhoa,nobs,alpha);

ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
[F,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,sspf,ssmo,nperms,dclags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

sig_p  = significance(pval,alpha,mhtc);
% (We should probably check for failed permutation estimates here.)

% Permutation test significance test (adjusting for multiple hypotheses).

% pval_p = empirical_pval(F,FNULL);
% sig_p  = significance(pval_p,alpha,mhtc);

%% 

pdata = {connectivity_matrix, F; sigLR, sig_p};

ptitle = {'PWCGC (actual)','PWCGC (SS estimated)'; 'LR-test','Permutation test'};

plot_gc(pdata,ptitle,[],[],[]);

%% Functional connectivity

% [n, m, N] = size(X);
% 
% % pairwise conditional MI :
% 
% lag = 0;
% V = tsdata_to_autocov(X,lag);
% [MI, stats] = cov_to_pwcmi(V,m,N);
% 
% pval = stats.LR.pval;
% alpha = 0.05;
% correction = 'HOLM';
% sig = significance(pval,alpha,correction);
% 
% pdata = {connectivity_matrix, MI; sig, sigLR};
% 
% ptitle = {'PWCGC (actual)','MI (estimated)'; 'MI (sig)','LR test'};
% 
% plot_gc(pdata,ptitle,[],[],[]);

