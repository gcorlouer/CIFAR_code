function [F, VAR, VARmoest, sig] = pwcgc_from_VARmodel(X, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate VAR model based pairwise conditional granger causality from 
% time series X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'OLS';
defaultPlotm = 1;
defaultAlpha = 0.05;
defaultMhtc = 'FDRD';
defaultLR = true;

p = inputParser;

addRequired(p, 'X')
addParameter(p, 'mosel', defaultMosel, @isscalar); 
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);
addParameter(p, 'alpha', defaultAlpha)
addParameter(p, 'mhtc', defaultMhtc)
addParameter(p, 'LR', defaultLR)


parse(p, X, varargin{:});

mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;
alpha = p.Results.alpha;
mhtc =  p.Results.mhtc;
LR = p.Results.LR;

%% VAR modeling

[VAR, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ... 
                             'moregmode', moregmode, 'plotm', plotm );

%% Pairwise conditional GC

V = VAR.V;
A = VAR.A;

[F,pval] = var_to_pwcgc(A,V,X,moregmode);
% Put diagonal terms which are NaN by default to 0
F(isnan(F))=0;

if LR == true
    stats = pval.LR;
else 
    stats = pval.FT;
end
sig = significance(stats,alpha,mhtc);
