function F = pairwise_conditional_GC(X, varargin)

defaultMultitrial = true;
defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'OLS';
defaultPlotm = 1;
defaultSliding = false;

p = inputParser;

addRequired(p, 'X')
addParameter(p, 'multitrial', defaultMultitrial)
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);

parse(p, X, varargin{:});

multitrial = p.Results.multitrial;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;

%% Modeling whole epoched data
[n, m, N] = size(X);

% VAR model

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', plotm );
% SS model

[SSmodel, SSmoest] = SSmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', plotm );


%% Sliding Pairwise GC effect size


F = ss_to_pwcgc(SSmodel.A, ... 
        SSmodel.C, SSmodel.K, SSmodel.V);


F(isnan(F))=0;
