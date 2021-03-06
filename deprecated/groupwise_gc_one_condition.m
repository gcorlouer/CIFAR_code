% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('fs','var') fs = 250; end 
if ~exist('ncat','var') ncat = 11; end % 10: rest, 11: face, 12: place

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 2; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 20; end % Max model order 
if ~exist('moregmode', 'var') moregmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end % 
if ~exist('LR', 'var') LR = true; end % 

% Temporal window in seconds

if ~exist('tmin', 'var') tmin = 0.3; end
if ~exist('tmax', 'var') tmax = 1; end
if ~exist('t_0', 'var') t_0 = -0.050; end


%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

fn = fieldnames(time_series);

X = time_series.(fn{ncat});
time = time_series.time;

channel_to_population = time_series.channel_to_population;
populations = time_series.populations;

%% Crop signal

[X, time] = crop_signal(X, time, 'tmin', tmin, 'tmax', tmax, 'fs', fs, 't_0', t_0);

%% Detrend
X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% VAR analysis

[F, VARmodel, VARmoest, sig] = pwcgc_from_VARmodel(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'LR', LR);

TE = GC_to_TE(F, fs);

%% Functional group TE
DK_to_indices = time_series.DK_to_indices; 
group = populations; % Or take fieldname populations

fn_pop = fieldnames(group);
npop = size(fn_pop,1);
clear fgroup_TE % useful when looping over script
for i = 1:npop
    for j=1:npop
        fgroup_TE(i,j) = mean2(TE(group.(fn_pop{i}),group.(fn_pop{j})));
    end
end

%% Anatomical group TE

% DK_to_indices = time_series.DK_to_indices;
% fn_DK = fieldnames(DK_to_indices);
% nDK = size(fn_DK,1);
% 
% for i = 1:nDK
%     for j=1:nDK
%         group_TE(i,j) = mean2(TE(DK_to_indices.(fn_DK{i}),DK_to_indices.(fn_DK{j})));
%     end
% end

%% Plot functional 


% max_TE = max(fgroup_TE, [],'all');
% clims = [0 max_TE];
% population = channel_to_population;
% plot_title = ['Transfer entropy ', fn{ncat}];  
% plot_pcgc(fgroup_TE, clims, fn_pop)
% title(plot_title)


%% Plot anatomical

% max_TE = max(agroup_TE, [],'all');
% clims = [0 max_TE];
% population = channel_to_population;
% plot_title = ['Transfer entropy ', fn{ncat}];  
% plot_pcgc(agroup_TE, clims, fn_DK)
% title(plot_title)

