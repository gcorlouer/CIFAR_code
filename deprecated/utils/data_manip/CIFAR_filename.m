%% Select filename 
%% Parameters
% BP= true or false; bipolar montage or raw
% subject: subject name
% preproc: preproc or noprproc data
% task : 'rest_baseline_1', 'rest_baseline_1','sleep', 'stimuli_1', 'stimuli_2';
%% 
function [fname, dataset] = CIFAR_filename(varargin)

defaultBP = true;
defaultSubject = 'DiAs';
defaultTask = 'stimuli_1';
defaultExt = '.set';
defaultPreproc = false; 
defaultPforder = 10;
defaultThresh = 3;
defaultBasis = 'sinusoids'; % Or polynomial (check preprocessing)

p = inputParser;

addParameter(p, 'BP', defaultBP, @islogical);
addParameter(p, 'subject', defaultSubject, @isvector);
addParameter(p, 'task', defaultTask,@isvector);
addParameter(p, 'ext', defaultExt,@isvector);
addParameter(p, 'preproc', defaultPreproc,@islogical);
addParameter(p, 'pforder', defaultPforder, @isscalar);
addParameter(p, 'thresh' , defaultThresh,@isscalar);
addParameter(p, 'basis', defaultBasis,@isvector);

parse(p, varargin{:});

if p.Results.BP
    dataset = [p.Results.subject '_' 'freerecall_' p.Results.task '_preprocessed_BP_montage'];
else
    dataset = [p.Results.subject '_' 'freerecall_' p.Results.task '_preprocessed'];
end

fname = [dataset p.Results.ext];

end

function preprocDir = ppDir(varargin)

defaultPreproc = false; 
defaultPforder = 10;
defaultThresh = 3;
defaultBasis = 'sinusoids'; % Or polynomial (check preprocessing)

p = inputParser;

addParameter(p, 'preproc', defaultPreproc,@islogical);
addParameter(p, 'pforder', defaultPforder, @isscalar);
addParameter(p, 'thresh' , defaultThresh,@isscalar);
addParameter(p, 'basis', defaultBasis,@isvector);

parse(p, varargin{:});

if p.Results.preproc == true
    preprocDir = ['preproc_','_noBadchans_detrend_pforder_' ... 
        num2str(p.Results.pforder) p.Results.basis '_rmv_outlier_' ... 
        num2str(p.Results.thresh) 'std']; % Check that name of dir is correct!
else
    preprocDir = 'nopreproc';
end

end
