%% Simulate time series to test CIFAR GC analysis
% Simulate 3 multitrial VAR model.

%% Parameters
rng(1);
ntrials = 56;
nchan = 14;
morder = 5;
rho = 0.90;
nobs = 120;
regmode = 'OLS';
momax = 10;
alpha = 0.05;
pacf = true;
plotm = 1;
verb = 0;
n_cdt = 3;
q = 0;
fres = 1024;
fs = 100;
input_parameters;
%% Simulation
% Simulate multitrial, multi conditions time series, with different VAR
% model and connectivity matrix for each condition

X = zeros(nchan, nobs, ntrials, n_cdt);
connectivity_matrix = zeros(nchan, nchan, n_cdt);

for i=1:n_cdt
    [X(:,:,:,i), var_coef, corr_res, connectivity_matrix(:,:,i)] =  ... 
    var_simulation(nchan, 'morder', morder, 'specrad', rho, 'nobs', nobs, 'ntrials', ntrials);
end


%% MI estimation
MI = zeros(nchan, nchan, n_cdt);
sig_MI = zeros(nchan, nchan, n_cdt);

for i=1:n_cdt
    [MI(:,:,i), sig_MI(:,:,i)] = ts_to_MI(X(:,:,:,i), 'q', q, 'mhtc', mhtc, 'alpha', alpha);
end
%% GC estimation

F = zeros(nchan, nchan, n_cdt);
sig_GC = zeros(nchan, nchan, n_cdt);

for i=1:n_cdt
    [F(:,:,i), sig_GC(:,:,i)] = ts_to_var_pcgc(X(:,:,:,i),'morder', morder,...
        'regmode', regmode,'alpha', alpha,'mhtc', mhtc, 'LR', LR);
end

%% Save file

fname = 'simulated_FC.mat';
datadir = fullfile('~','projects', 'CIFAR', 'data_fun');
fpath = fullfile(datadir, fname);

save(fpath, 'F', 'sig_GC', 'MI', 'sig_MI', 'connectivity_matrix')
disp('Saved simulated functional connectivity')
%% Estimate spectral GC

for i=1:n_cdt
    f(:,:,:,i) = ts_to_var_spcgc(X(:,:,:,i), 'regmode',regmode, 'morder',morder,...
        'fres',fres, 'fs', fs);
end

fname = 'simulated_spectral_GC.mat';
datadir = fullfile('~','projects', 'CIFAR', 'data_fun');
fpath = fullfile(datadir, fname);

save(fpath, 'f')