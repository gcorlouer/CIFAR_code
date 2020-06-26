%% Parameters 

if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('montage','var') montage = 'BP'; end
if ~exist('condition','var') condition_ext = '_epoch.mat'; end
if ~exist('GC_ext', 'var') GC_ext = ['_GC',condition_ext]; end
% Modeling
if ~exist('multitrial', 'var') multitrial = true; end
if ~exist('mosel', 'var') mosel = 4; end 

%% Import data

datadir = fullfile('~','projects','CIFAR','data_fun');
fname = CIFAR_filename('ext', condition_ext, 'task', task);
fpath = fullfile(datadir, fname);
dataset = load(fpath);

ch_names = dataset.ch_names;
ch_index = dataset.ch_index;
ROIs = dataset.ROI;

Y = dataset.epochs;
X = permute(Y, [2 3 1]);
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
    xticklabels(ROIs)
    yticklabels(flip(ROIs))
    colorbar
else 
    trial_stamp = 1:1:size(F,3);
    F_pair = squeeze(F(1,2,:));
    plot(trial_stamp, F_pair)
end

%% Save GC estimation
GC_name = CIFAR_filename('ext',GC_ext, 'task', task);
GC_path = fullfile(datadir, GC_name);
save(GC_path, 'F');