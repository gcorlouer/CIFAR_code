%% Parameters 

if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end
if ~exist('cat','var') cat = 'Face'; end % Presented category

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end
if ~exist('mosel', 'var') mosel = 4; end 

%% Import data

ext = ['_HFB_visual_epoch_', cat, '.mat']; 
datadir = cf_datadir();
fname = CIFAR_filename('ext', ext, 'task', task, 'BP', BP);
fpath = fullfile(datadir, fname);
dataset = load(fpath);

ch_names = dataset.chan;
ROIs = dataset.brodman;
category = dataset.category;
DK = dataset.DK;

Y = dataset.data;
X = permute(Y, [2 3 1]); % Select good format for GC analysis
nchans = size(X,1);
%% Modeling

% VAR model 
tic
[VARmodel, moest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
toc
% SS model

tic
[SSmodel, moest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc   

%% Pairwise GC estimation

F = multi_ss_to_pwcgc(SSmodel, nchans, multitrial);
%F = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

if multitrial==true
    plot_gc(F,'PWCGC (envelope)',[],[],0);
    xticklabels(ch_names)
    yticklabels(flip(ch_names))
    colorbar
else 
    trial_stamp = 1:1:size(F,3);
    F_pair = squeeze(F(3,7,:));
    plot(trial_stamp, F_pair)
end

%% Save GC estimation
if multitrial == true
    GC_ext = ['_GC_multi',ext];
else
    GC_ext = ['_GC_sliding', ext];
end
GC_name = CIFAR_filename('ext',GC_ext, 'task', task, 'BP', BP);
GC_path = fullfile(datadir, GC_name);
save(GC_path, 'F','ch_names','ROIs', 'category');