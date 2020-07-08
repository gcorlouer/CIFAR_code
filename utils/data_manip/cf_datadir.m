function datadir = cf_datadir(varargin)
defaultSubject = 'DiAs';
defaultProc = 'preproc';

p = inputParser;

addParameter(p, 'subject', defaultSubject, @isvector);
addParameter(p, 'proc', defaultProc,@islogical);

parse(p, varargin{:});

subject = p.Results.subject;
proc = p.Results.proc;

datadir = fullfile('~','CIFAR_data','iEEG_10', 'subjects');
datadir = fullfile(datadir, subject, 'EEGLAB_datasets', proc);

end
