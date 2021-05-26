%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script run functional connectivity analysis on time series of one
% subject. Estimates mutual information and then pairwise conditional 
% Granger causality (GC).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

% Mutual information
if ~exist('q', 'var')    q = 0; end % Covariance lag

% Modeling
if ~exist('moregmode', 'var') regmode = 'OLS'; end % OLS or LWR
if ~exist('morder', 'var')    morder = 5; end % Model order
if ~exist('momax', 'var') momax = 20; end
pacf = true;
plotm = 1;
verb = 0;

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple testing correction
if ~exist('LR', 'var') LR = true; end % If false F test