% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('fs','var') fs = 100; end 
if ~exist('ncat','var') ncat = 2; end 

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

%%

datadir = fullfile('~', 'projects', 'CIFAR', 'CIFAR_data', 'iEEG_10', ... 
    'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_visual_HFB_all_categories.mat'];
fpath = fullfile(datadir, fname);

time_series = load(fpath);

fn = fieldnames(time_series);

X = time_series.(fn{ncat});

channel_to_population = time_series.channel_to_population;
channel_to_population = channel_to_population(:, 1:2);
%X = X(:, srange, :);
X = detrend_HFB(X, 'deg_max', 2);
[n, m, N] = size(X);

%% VAR modeling

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode, 'plotm', 1 );

%% Groupwise GC

populations_to_channels = time_series.populations_to_channel;
pop = fieldnames(populations_to_channels);
npop = size(pop,1);
for i=1:npop
    ipop = i;
    for j=1:npop
        jpop = j;
        if ipop == jpop
            stats(i,j) = 1;
        else
            
            x = populations_to_channels.(pop{ipop});
            y = populations_to_channels.(pop{jpop});
            if isempty(x) | isempty(y)
                continue
            else
            A = VARmodel.A ; V = VARmodel.V ; 
            [group_GC(ipop,jpop), group_pval(ipop,jpop)] = var_to_mvgc(A,V,x,y,X,moregmode);
            stats(i,j) = group_pval(i,j).LR;
            end
        end
    end
end

%% Stats

sig = significance(stats,alpha,mhtc);

%% Plot groupwise GC and stats
TE = GC_to_TE(group_GC, fs);

clims = [0 1];
population = {'V1', 'V2', 'Place', 'Face'};
plot_title = ['Transfer entropy ', fn{ncat}];  
subplot(1,2,1)
plot_pcgc(TE, clims, population')
title(plot_title)
subplot(1,2,2)
plot_pcgc(sig, [0 1], population')
title('LR test')

