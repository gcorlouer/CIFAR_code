%Startup stuff
% Run script in code_matlab rep inside CIFAR project directroy
global CIFAR_version;
CIFAR_version.major = 1;
CIFAR_version.minor = 0;

rootdir = getenv('USERPROFILE');
%fprintf('[CIFAR startup] Initialising CIFAR version %d.%d\n', PsyMEG_version.major, PsyMEG_version.minor);

% Home dir

global home_dir CIFAR_root code_root% parent folder of CIFAR directory
home_dir = fullfile('~');
CIFAR_root = fullfile(home_dir, 'projects', 'CIFAR') ; 
addpath(genpath(CIFAR_root));
rmpath(fullfile(CIFAR_root, 'code_matlab','deprecated')); % remove deprecated code to avoid confusion
fprintf('[CIFAR startup] Added path %s and appropriate subpaths\n',CIFAR_root);

% Initialize mvgc library

global mvgc_root;
mvgc_root = fullfile(home_dir,'toolboxes','MVGC2');
assert(exist(mvgc_root,'dir') == 7,'bad MVGC path: ''%s'' does not exist or is not a directory',mvgc_root);
cd(mvgc_root);
startup;
cd(CIFAR_root);

% Add other useful toolboxes

global toolbox_dir ESN_dir noisetool eeglab_root LPZ_dir

cd(home_dir)
toolbox_dir = fullfile(home_dir,'toolboxes');
%ESN_dir = fullfile(toolbox_dir,'EchoState-GrangerCausality');
noisetool = fullfile(toolbox_dir,'NoiseTools');
eeglab_root = fullfile(toolbox_dir,'eeglab2019_1');
LPZ_dir = fullfile(toolbox_dir, 'fLZc');

addpath(genpath(fullfile(LPZ_dir)));
addpath(genpath(fullfile(ESN_dir)));
addpath(genpath(fullfile(noisetool)));
rmpath(fullfile(noisetool, 'COMPAT'));
addpath(genpath(fullfile(eeglab_root)));

cd(CIFAR_root)

% Path to plot figures

% global fig_path_root
% fig_path_root = fullfile(CIFAR_root, 'figures');
% addpath(genpath(fig_path_root));

% Initialize EEGLab

% global eeglab_root;
% eeglab_root = fullfile(getenv('MATLAB_EEGLAB'));
% addpath(eeglab_root);
% addpath(genpath(fullfile(eeglab_root,'functions')));

%Add Fieldtrip

global fieldtrip_root
cd(home_dir)
fieldtrip_root = fullfile(home_dir,'toolboxes','fieldtrip');
addpath(fieldtrip_root)
ft_defaults % add main fieldtrip functions
cd(CIFAR_root)

% Amend for your CIFAR data set-up

global cfdatadir cffigdir cfsubdir cfmetadata
cfdatadir  = fullfile(CIFAR_root,'source_data');
cffigdir   = fullfile(cfdatadir,'iEEG_10','figures');
cfsubdir   = fullfile(cfdatadir,'iEEG_10','subjects');
cfmetadata = fullfile(cfdatadir,'metadata','metadata.mat');
addpath(fullfile(genpath(cfdatadir)))

% Electrode mapping

global ecog_map_root fsaverage_dir plot_elecdir;
ecog_map_root = fullfile(code_root,'utils','electrode_mapping');
plot_elecdir  = fullfile(ecog_map_root,'plot_electrodes_on_brain','plot_brain');
fsaverage_dir = fullfile(ecog_map_root, 'fsaverage'); %average brain path
addpath(genpath(ecog_map_root));

% Image viewers

% global rasviewer pdfviewer svgviewer
% rasviewer = 'feh';
% pdfviewer = 'mupdf';
% svgviewer = 'inkview';

% Get screen size

global screenxy

s = get(0,'ScreenSize');
screenxy = s([3 4]);

% Make all plot fonts bigger!

set(0,'DefaultAxesFontSize',20);
set(0,'DefaultTextFontSize',18);

% Make plot colours sane (like the old MATLAB)!

set(groot,'defaultAxesColorOrder',[0 0 1; 0 0.5 0; 1 0 0; 0 0.75 0.75; 0.75 0 0.75; 0.75 0.75 0; 0.25 0.25 0.25]);

% Dock figures
set(0,'DefaultFigureWindowStyle','docked')

fprintf('[CIFAR startup] Initialised (you may re-run `startup'' at any time)\n');
