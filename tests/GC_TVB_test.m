%% Parameters

% Estimation

mosel = 1;
multitrial = true;
regmode = 'OLS';

alpha = 0.05;
mhtc = 'FDR';
nperms =100; 

% TVB test

dataset = load('tvb_test.mat');
X = dataset.data;
time = dataset.time;
X = X'; 

[tsdim, nobs, ntrials] = size(X);

%% VAR estimation 

% VAR model estimation

tic
[VARmodel, varmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc

% Estimated time-domain pairwise-conditional Granger causalities

ptic('*** var_to_pwcgc... ');
[F_var,pval] = var_to_pwcgc(VARmodel.A, VARmodel.V, X, regmode);
ptoc;

% Significance test (F-test and likelihood ratio), adjusting for multiple hypotheses.

sigFT = significance(pval.FT,alpha,mhtc);
sigLR = significance(pval.LR,alpha,mhtc);

%% SS model estimation

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

%% Permutation test with rotation

sspf = 2*varmoest(mosel);
ssmo = SSmoest(mosel);
dclags = decorrlags(SSmodel.rhoa,nobs,alpha);

ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
[F_ss,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,sspf,ssmo,nperms,dclags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

sig_p  = significance(pval,alpha,mhtc);

%% 

pdata = {F_var, F_ss; sigLR, sig_p};

ptitle = {'PWCGC (VAR)','PWCGC (SS)'; 'LR-test','Permutation test'};

plot_gc(pdata,ptitle,[],[],[]);
