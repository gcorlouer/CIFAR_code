%% Bootstrap estimation of GC statistics
% Algorithm:
% From N trials time series, draw K trials with replcaement to construct 
% K-trials time series.
% Estimate VAR model order, parameters and GC on K-trials time series
% Repeat B times and computie standard error of GC 
% 
%% Simulate N trials time series
tic
% Parameters (similar to CIFAR study)
ntrials = 56; nchan = 14; morder = 5; rho = 0.98; nobs = 120; regmode = 'OLS';
momax = 10; alpha = 0.05; pacf = true; plotm = []; verb = 0; n_cdt = 3;
q = 0; fres = 1024; fs = 100; replacement = true; K = ntrials; B = 1000;

input_parameters;
% Simulate VAR time series
[X, var_coef, corr_res, connectivity_matrix] = var_simulation(nchan, ...
    'morder', morder, 'specrad', rho, 'nobs', nobs, 'ntrials', ntrials);

F_B = zeros(nchan, nchan, B);

% Estimate GC 
[~,~,mohqc,~] = tsdata_to_varmo(X, ... 
            momax,regmode,alpha,pacf,plotm,verb);
    morder = mohqc;

[F, ~] = ts_to_var_pcgc(X,'morder', morder,...
            'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
F_mean = mean(F, 'all');
%% Resample data
% Sample K trials with replacement
for ib=1:B
    sampled_trials = randsample(ntrials, K, replacement);
    X_b = zeros(nchan, nobs, K);
    for i=1:K
        X_b(:,:,i) = X(:,:,sampled_trials(i));
    end
    %% Estimate VAR model order and GC 

    [~,~,mohqc,~] = tsdata_to_varmo(X_b, ... 
            momax,regmode,alpha,pacf,plotm,verb);
    morder = mohqc;

    [F_B(:,:,ib), ~] = ts_to_var_pcgc(X_b,'morder', morder,...
            'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Compute standard error and confidence interval with standard error
% Note: In theory this method of estimating CI is not recomanded because
% asymptotic distribution of GC is not normal.

se = std(F_B, 0, 3);
se_mean = mean(se, 'all');
F_up = F + 1.95*se;
F_down = F - 1.95*se;
F_up = mean(F_up, 'all');
F_down = mean(F_down, 'all');

%% Compute Bootstrap pivotal confidence interval
% This method is better in theory and asymptotically converges to 95% CI
% Compute 1-alpha Bootstrap pivotal CI 
% Note in practice it seems relatively consistent with the SE estimation of
% CI

Fq_up = 2*F - quantile(F_B,alpha/2,3);
Fq_down = 2*F - quantile(F_B,1-alpha/2,3);
Fq_up = mean(Fq_up, 'all');
Fq_down = mean(Fq_down, 'all');

toc

%% Plot histogram of F_B (to give an idea of how many bootstrap to run)

idx = F_B>0;
nbins = 100;
histogram(F_B(idx), nbins);
fig_path = fullfile('~','projects','CIFAR', 'figures','histogram_simulated_boostrapp.png');
saveas(gcf, fig_path)