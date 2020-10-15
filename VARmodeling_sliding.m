function [VARmodel, moest] = VARmodeling_sliding(X, varargin)

defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';
defaultPlotm = 1;
defaultMultitrial = true;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  
addParameter(p, 'plotm', defaultPlotm, @isscalar);  
addParameter(p, 'multitrial', defaultMultitrial, @islogical);  

parse(p, X, varargin{:});

X = p.Results.X;
fs = p.Results.fs;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm; 

[nchan, nobs, ntrials, nwin] = size(X);

for w=1:nwin
    
 [moest(1,w),moest(2,w), moest(3,w), moest(4,w)] = ... 
        tsdata_to_varmo(X(:,:,:,w), momax,moregmode, ...
        [], [], plotm);
    % VAR modeling
    [VARmodel(w).A, VARmodel(w).V, VARmodel(w).E] = tsdata_to_var(X(:,:,:,w), ...
        moest(mosel),moregmode); 
    % Spectral radius
    VARmodel(w).info = var_info(VARmodel(w).A,VARmodel(w).V);
end

