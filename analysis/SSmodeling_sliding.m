function [SSmodel, moest] = SSmodeling_sliding(X, varargin)

defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';
defaultPlotm = 1;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);  

parse(p, X, varargin{:});

X = p.Results.X;
fs = p.Results.fs;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm; 

[nchan, nobs, ntrials, nwin] = size(X);

for w = 1:nwin
    % VAR model estimation
    [moest(1,w),moest(2,w), moest(3,w), moest(4,w)] = ... 
        tsdata_to_varmo(X(:,:,:,w), momax,moregmode, ...
        [], [], plotm);
    % SSm svc estimation
    SSmodel(w).pf = 2*moest(mosel,w); %;  % Bauer recommends 2 x VAR AIC model order
    [SSmodel(w).mosvc,~] = tsdata_to_sssvc(X,SSmodel(w).pf, ... 
        [], plotm);
    % SS parameters
    [SSmodel(w).A, SSmodel(w).C, SSmodel(w).K, ... 
        SSmodel(w).V] = tsdata_to_ss(X(:,:,:,w), SSmodel(w).pf, SSmodel(w).mosvc);
    % SS info: spectrail radius and mii
    info = ss_info(SSmodel(w).A, SSmodel(w).C, ... 
        SSmodel(w).K, SSmodel(w).V, 0);
    SSmodel(w).rhoa = info.rhoA;
    SSmodel(w).rhob = info.rhoB;
    SSmodel(w).mii(w) = info.mii;
end