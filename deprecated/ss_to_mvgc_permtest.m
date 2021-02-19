function [F, sig_p] = SSmodel_to_mvgc_permtest(X, SSmodel, target_chan, source_chan, varargin)

defaultAlpha = 0.05;
defaultNperms = 100; 
defaultMhtc = 'FDR';

p = inputParser;

addRequired(p, 'X');
addRequired(p, 'SSmodel');
addRequired(p, 'target_chan');
addRequired(p, 'source_chan');
addParameter(p, 'alpha', defaultAlpha, @isscalar);
addParameter(p, 'nperms', defaultNperms, @isscalar);
addParameter(p, 'mhtc', defaultMhtc, @vector);

parse(p, X, SSmodel, target_chan, source_chan, varargin{:});

X = p.Results.X;
SSmodel = p.Results.SSmodel;
target_chan =  p.Results.target_chan;
source_chan =  p.Results.source_chan;
alpha = p.Results.alpha;
nperms = p.Results.nperms;
mhtc = p.Results.mhtc;

[nchan, nobs, ntrials] = size(p.Results.X);
dclags = decorrlags(SSmodel.rhoa,nobs,alpha);
sspf = SSmodel.pf;
ssmo = SSmodel.mosvc;


ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
[F,pval,A,C,K,V] = tsdata_to_ss_mvgc_permtest(X,target_chan,source_chan,sspf,ssmo,nperms,dclags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

sig_p  = significance(pval,alpha,mhtc);