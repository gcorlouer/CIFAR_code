function [SSmodel, moest] = slide_ss_parser_test(X, ts, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slide state space modeling on time series
% 
%%% Input
% Time series, time window and regression parameters
%%% Output
% State space model inovation form parameters, AIC model order and SVC in 
% each time window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As state space model parameters change size along sliding windows, try to
% Create a structure array instead

defaultFs = 500;
defaultWind = [5 1];
defaultTstamp = 'mid';
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'LWR';

p = inputParser;

addRequired(p,'X');
addRequired(p,'ts');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'wind', defaultWind, @isvector);
addParameter(p, 'tstamp', defaultTstamp, @vector);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  


parse(p, X, ts, varargin{:});

[X, ~, nwin, nwobs, nsobs, ~, ~] = sliding(p.Results.X, p.Results.ts, p.Results.fs, p.Results.wind, p.Results.tstamp);

moest = zeros(nwin,1);

% Slide window

for w = 1:nwin
	o = (w-1)*nsobs;      % window offset
	W = X(:, o+1:o+nwobs); % the window\\
	[moest(w,1),moest(w,2),moest(w,3),moest(w,4)] = tsdata_to_varmo(W,p.Results.momax,p.Results.moregmode);
    SSmodel(w).pf = 2*moest(w,p.Results.mosel); %;  % Bauer recommends 2 x VAR AIC model order
    [SSmodel(w).mosvc,~] = tsdata_to_ssmo(W,SSmodel(w).pf);
    [SSmodel(w).A, SSmodel(w).C, SSmodel(w).K, SSmodel(w).V] = tsdata_to_ss(W, SSmodel(w).pf, SSmodel(w).mosvc);
    info = ss_info(SSmodel(w).A, SSmodel(w).C, SSmodel(w).K, SSmodel(w).V, 0);
	SSmodel(w).rhoa = info.rhoA;
	SSmodel(w).rhob = info.rhoB;
	SSmodel(w).mii(w) = info.mii;
end

