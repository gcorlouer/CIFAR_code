%% Simulate multitrial VAR data and estimate per trial model order
% Observation:
% If we simulate data in such a way, even with 1000 observation and stable
% multitrial model, VAR estimation on individual trials yield unstable model
% estimation. 
%% Parameters
rng(1);
ntrials = 56;
tsdim = 4;
morder = 5;
rho = 0.90;
nobs = 1000;
regmode = 'OLS';
momax = 10;
alpha = 0.05;
pacf = true;
plotm = 1;
verb = 0;
%% Simulation

[X, var_coef, corr_res, connectivity_matrix] =  ... 
var_simulation(tsdim, 'morder', morder, 'specrad', rho, 'nobs', nobs, 'ntrials', ntrials);

%% Estimate VAR model order on each trial
moaic = zeros(ntrials, 1);
mobic = zeros(ntrials, 1);
mohqc = zeros(ntrials, 1);
molrt = zeros(ntrials, 1);

for itrial=1:ntrials
    [moaic(itrial),mobic(itrial),mohqc(itrial),molrt(itrial)] =  ... 
        tsdata_to_varmo(X(:,:,itrial), momax,regmode,alpha,pacf,plotm,verb);
end


%% Estimate VAR models parameters on each trials
morder = 6;
for i=1:ntrials
    VAR(i) = ts_to_var_parameters(X(:,:,i), 'morder', morder, 'regmode', regmode);
end 

%% Check that VAR estimation is working 

morder = 5;
VAR = ts_to_var_parameters(X, 'morder', morder, 'regmode', regmode);


