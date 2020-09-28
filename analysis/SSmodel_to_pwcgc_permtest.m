function [F, sig_p] = SSmodel_to_pwcgc_permtest(X, SSmodel, varargin)

defaultAlpha = 0.05;
defaultNperms = 100; 
defaultMhtc = 'FDRD';

p = inputParser;

addRequired(p, 'X');
addRequired(p, 'SSmodel');
addParameter(p, 'alpha', defaultAlpha, @isscalar);
addParameter(p, 'nperms', defaultNperms, @isscalar);
addParameter(p, 'mhtc', defaultMhtc, @vector);

parse(p, X, SSmodel, varargin{:});

X = p.Results.X;
SSmodel = p.Results.SSmodel;
alpha = p.Results.alpha;
nperms = p.Results.nperms;
mhtc = p.Results.mhtc;

[nchan, nobs, ntrials] = size(p.Results.X);
dclags = decorrlags(SSmodel.rhoa,nobs,alpha);
sspf = SSmodel.pf;
ssmo = SSmodel.mosvc;


ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
[F,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,sspf,ssmo,nperms,dclags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

sig_p  = significance(pval,alpha,mhtc);