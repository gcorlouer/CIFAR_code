%% FC_analysis.m
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('montage','var') montage = 'BP'; end
if ~exist('condition','var') condition_ext = '_sliding.mat'; end
if ~exist('GC_ext', 'var') FC_ext = ['_FC',condition_ext]; end
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

%% Functional connectivity 

group = {1:10};
connectivity = 'intra'; 

[MI, stats] = multi_info(X, 'connectivity', connectivity, 'multitrial', multitrial, 'group', group);

%% Interpret Functional connectivity

