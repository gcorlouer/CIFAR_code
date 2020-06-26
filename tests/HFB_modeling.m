% Test VAR model on HFB 
%% Load data
datadir = fullfile('~','projects','CIFAR','data_fun');
datapath = fullfile('~','projects','CIFAR','data_fun', ... 
    'DiAs_freerecall_rest_1_preprocessed_BP_montage_epoch_face_rest.mat');
dataset = load(datapath);
Y = dataset.epochs_picks_rest;
Y_rest = dataset.epochs_picks_rest;

ch_names = dataset.ch_names;
ch_index = dataset.ch_index;
ROIs = dataset.ROI_pick;

X = permute(Y, [2 3 1]);
X_rest = permute(Y_rest, [2 3 1]);
% VAR model 
tic
[VARmodel, moest] = VARmodeling(X, 'momax', 30, 'mosel', 4, 'multitrial', true);
toc
% SS model

tic
[SSmodel, moest] = SSmodeling(X, 'mosel', 4, 'multitrial', true);
toc   

% GC estimation

F_rest = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

plot_gc(F_rest,'PWCGC (envelope)',[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))
colorbar

% Save GC estimation
GC_name = 'DiAs_freerecall_rest_1_preprocessed_BP_montage_epoch_face_rest_GC.mat';
GC_path = fullfile(datadir, GC_name);
save(GC_path, 'F_rest');
%% Load data
datapath = fullfile('~','projects','CIFAR','data_fun', ... 
    'DiAs_freerecall_stimuli_1_preprocessed_BP_montage_epoch_face_stim.mat');
dataset = load(datapath);
Y = dataset.epochs_picks_stim;
Y_stim = dataset.epochs_picks_stim;
X = permute(Y, [2 3 1]);
X_stim = permute(Y_stim, [2 3 1]);
% VAR model 
tic
[VARmodel, moest] = VARmodeling(X, 'momax', 30, 'mosel', 4, 'multitrial', true);
toc
% SS model

tic
[SSmodel, moest] = SSmodeling(X, 'mosel', 4, 'multitrial', true);
toc

% GC estimation

F_stim = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

plot_gc(F_stim,'PWCGC (envelope)',[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))
colorbar

GC_name = 'DiAs_freerecall_stimuli_1_preprocessed_BP_montage_epoch_face_stim_GC.mat';
GC_path = fullfile(datadir, GC_name);
save( GC_path, 'F_stim');
%% Compare rest/stimulus GC 
plot_gc({F_rest, F_stim},{'PWCGC (rest)','PWCGC (stimuli)'},[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))
colorbar
%% 
subplot(2,1,1)
plot_gc(F_rest,'PWCGC (rest)',[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))
colorbar
subplot(2,1,2)
plot_gc(F_stim,'PWCGC (stim)',[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))     
colorbar
%% 
%% LPz complexity
% Calculate complexities for different quantisation levels, and load random string complexities
evok = mean(X,3);

maxn = size(evok,2);
maxq = 5;
%fs = 500;
nchan = size(X,1);
c      = zeros(nchan,maxn,maxq);             % complexities of x
crnd   = zeros(nchan,maxn,maxq);             % random string complexities
qtiles = cell(maxq,1);                       % quantiles

for i = 1:size(X,1)
    x = squeeze(evok(i,:)');
    for q = 1:maxq                         % for each quantisation
        fprintf('processing qauntisation %d of %d... ',q,maxq);
        d = q+1;                           % alphabet size = number of quantiles + 1
        [s,qtiles{q}] = LZc_quantise(x,q); % quantise noise sequence by q quantiles; store quantiles
        c(i,:,q) = LZc(s,d);               % calculate "running" LZ complexity (i.e., for all sequence lengths to maximum)
        crnd(i,:,q) = LZc_crand(1:maxn,d);   % load random string mean complexities from file
        fprintf('done\n');
    end
    cnorm = c./crnd;                       % complexities normalised by mean complexity of random strings of same length and alphabet size
    
end
%% 
ROI_cell = cell(8,1);
for i=1:size(ch_index,2)
    ROI_cell{i,1} = ROIs(i,:);
end
%% Plot complexities 

n = (1:maxn)'; % sequence lengths
for i=1:nchan
    semilogx(n,squeeze(cnorm(i,:,1)));
    hold on
end
ylim([0 1.2])
yline(1,'color','k');
title('normalised LZ-complexity');
xlabel('sequence length (log-scale)');
ylabel('LZc');
leg = legend(ROI_cell{:,1},'location','southwest');
leg.Title.Visible = 'on';
title(leg,'channel');
grid on

%% 
[nchan, nobs, ntrials] = size(X);

cnorm_rest = running_LZc(X_rest);
cnorm_stim = running_LZc(X_stim);

cnorm_rest_mean = mean(cnorm_rest,2);
cnorm_rest_mean = squeeze(cnorm_rest_mean(:,1,nobs));
cnorm_rest_std = std(cnorm_rest,0,2);
cnorm_rest_std = squeeze(cnorm_rest_std(:,1,nobs));

cnorm_stim_mean = mean(cnorm_stim,2);
cnorm_stim_mean = squeeze(cnorm_stim_mean(:,1,nobs));
cnorm_stim_std = std(cnorm_stim,0,2);
cnorm_stim_std = squeeze(cnorm_stim_std(:,1,nobs));

%% Plot corresponding complexities

cnorm_mean = cat(2, cnorm_rest_mean, cnorm_stim_mean);
cnorm_std = cat(2, cnorm_rest_std, cnorm_stim_std);

% bar(cnorm_mean)
% ylim([0.4, 0.54])
% hold on
% errorbar(cnorm_mean, cnorm_std,'both', 'o')

leg = {'rest', 'stimuli'};
b = bar(cnorm_mean, 'grouped');

hold on
% Calculate the number of bars in each group
nbars = size(cnorm_mean, 2);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x',cnorm_mean, cnorm_std,'k','linestyle','none')
ylim([0.4, 0.54])
legend(leg)
title('Lempel-Ziv complexity rest and stimuli of HFB envelope, N=28 trials')
xticklabels(ROI_cell)
hold off
%% Estimate csd
% Take stimulus
autospec = false; fs = 500; fres = 1024;
csd = tsdata_to_cpsd(X,fs,[],[],fres,autospec);

F_csd_stim = cpsd_to_pwcgc(csd,[],100);

plot_gc(F_csd_stim,'PWCGC (stim)',[],[],0);
xticklabels(ROIs)
yticklabels(flip(ROIs))     
colorbar
%% Functional connectivity

F_stim_path = fullfile(datadir, 'F_stim_DiAs_rho993_svc41.mat');
F_rest_path = fullfile(datadir, 'F_rest_DiAs_rho978_svc43.mat');
save(F_stim_path, 'F_stim')
save(F_rest_path, 'F_rest')

%% Check VAR time series

m = size(X,2); N=size(X,3); fs = 500; dt = 1/fs; 

[tsdata,E,mtrunc] = var_to_tsdata(VARmodel.A,VARmodel.V,m,N);

ERP_VAR = mean(tsdata,3);
ERP_HFB = mean(X,3);
ERP = cat(1, ERP_VAR(4,:),ERP_HFB(4,:));
plot_tsdata(ERP,[],dt)


%% Check psd
fbin = 1024;
f = 1:1:size(S,3);
[S,H] = var_to_cpsd(VARmodel.A,VARmodel.V,fbin);
f = 1:1:size(S,3);

plot_autocpsd(squeeze(S(2,2,:)),f,fs,[]);