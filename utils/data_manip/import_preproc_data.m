function [X, dataset] = import_preproc_data(varargin)

defaultSubject = 'DiAs';
defaultTask = 'stimuli_1'; 
defaultBP = false;
defaultCat = 'Face';
defaultMultitrial = true;

p = inputParser;

addParameter(p, 'subject', defaultSubject)
addParameter(p, 'task', defaultTask)
addParameter(p, 'BP', defaultBP)
addParameter(p, 'cat', defaultCat)
addParameter(p, 'multitrial', defaultMultitrial)

parse(p, varargin{:});

subject = p.Results.subject;
task = p.Results.task;
BP = p.Results.BP;
cat = p.Results.cat;
multitrial = p.Results.multitrial;

ext = ['_HFB_visual_epoch_', cat, '.mat'];
datadir = cf_datadir('subject', subject);
fname = CIFAR_filename('ext', ext, 'task', task, 'BP', BP);
fpath = fullfile(datadir, fname);

dataset = load(fpath);
Y = dataset.data;
X = permute(Y, [2 3 1]); % Select good format for FC analysis
end 