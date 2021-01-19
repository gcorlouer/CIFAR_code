function [F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, varargin)

defaultMultitrial = true;
defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'OLS';
defaultPlotm = 1;
defaultAlpha = 0.05;
defaultMhtc = 'FDRD';
defaultLR = true;

p = inputParser;

addRequired(p, 'X')
addParameter(p, 'multitrial', defaultMultitrial)
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);
addParameter(p, 'alpha', defaultAlpha)
addParameter(p, 'mhtc', defaultMhtc)
addParameter(p, 'LR', defaultLR)


parse(p, X, varargin{:});

multitrial = p.Results.multitrial;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;
alpha = p.Results.alpha;
mhtc =  p.Results.mhtc;
LR = p.Results.LR;

%% Modeling whole epoched data
[n, m, N] = size(X);

% VAR model

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', plotm );

%% Sliding Pairwise GC effect size

V = VARmodel.V;
A = VARmodel.A;

[F,pval] = var_to_pwcgc(A,V,X,moregmode);
F(isnan(F))=0;

if LR == true
    stats = pval.LR;
else 
    stats = pval.FT;
end
sig = significance(stats,alpha,mhtc);
