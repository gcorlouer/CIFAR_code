if ~exist('fs','var') fs = 250; end 
if ~exist('ncat','var') ncat = 12; end % 11: rest, 12: face, 13: place

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % If false F test
%%
tsdim = 3; nobs = 76; specrad = 0.96; morder = 5; ntrials = 56;

[tsdata,var_coef, corr_res, connectivity_matrix] = var_simulation(tsdim, ... 
    'morder', morder, 'specrad', specrad, 'ntrials', ntrials, 'nobs', nobs);

%% VAR modeling

[VARmodel, VARmoest] = VARmodeling(tsdata, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', 1 );

%% GC estimation

V = VARmodel.V;
A = VARmodel.A;

[F,pval] = var_to_pwcgc(A,V,tsdata,moregmode);
F(isnan(F))=0;

if LR == true
    stats = pval.LR;
else 
    stats = pval.FT;
end

sig = significance(stats,alpha,mhtc);

TE = GC_to_TE(F, fs);
%% Plot

TE_max = max(TE, [],'all');
clims = [0 TE_max];
plot_title = ['Transfer entropy '];  
subplot(2,2,1)
plot_pcgc(TE, clims, channel_to_population)
title(plot_title)
subplot(2,2,2)
plot_pcgc(sig, [0 1], channel_to_population)
title('LR test')
subplot(2,2,3)
plot_pcgc(connectivity_matrix, [0 1], channel_to_population)
