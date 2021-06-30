function [F, SSmodel, SSmoest, sig] = pwcgc_from_SSmodel(X, varargin)

defaultMultitrial = true;
defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'OLS';
defaultPlotm = 1;
defaultAlpha = 0.05;
defaultNperms = 100;
defaultMhtc = 'FDRD';

p = inputParser;

addRequired(p, 'X')
addParameter(p, 'multitrial', defaultMultitrial)
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);
addParameter(p, 'alpha', defaultAlpha);  
addParameter(p, 'nperms', defaultNperms);  
addParameter(p, 'mhtc', defaultMhtc)

parse(p, X, varargin{:});

multitrial = p.Results.multitrial;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;
alpha = p.Results.alpha;
nperms = p.Results.nperms;
mhtc =  p.Results.mhtc;

%% Modeling whole epoched data
[n, m, N] = size(X);

% VAR model

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', plotm );
% SS model

[SSmodel, SSmoest] = SSmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', plotm );


%% Pairwise GC effect size


F = ss_to_pwcgc(SSmodel.A, ... 
        SSmodel.C, SSmodel.K, SSmodel.V);


F(isnan(F))=0;

%% Stats with cyclic permutation

sspf = 2*SSmoest(mosel);
ssmo = SSmodel.mosvc;
rho = SSmodel.rhoa;
nobs = m*N;
dclags = decorrlags(rho,nobs,alpha);

[F,pval,A,C,K,V] = tsdata_to_ss_pwcgc_permtest(X,sspf,ssmo,nperms,dclags);

sig = significance(pval,alpha,mhtc);

