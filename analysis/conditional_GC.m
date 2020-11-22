function [F, mean_F, visual_populations, chan_group] = conditional_GC(varargin)

defaultSubject = 'DiAs';
defaultTask = 'stimuli_1'; 
defaultBP = false;
defaultCat = 'Face';
defaultMultitrial = true;
defaultFs = 500;
defaultMosel = 1;
defaultMomax = 15;
defaultMoregmode = 'OLS';
defaultPlotm = 1;

p = inputParser;

addParameter(p, 'subject', defaultSubject)
addParameter(p, 'task', defaultTask)
addParameter(p, 'BP', defaultBP)
addParameter(p, 'cat', defaultCat)
addParameter(p, 'multitrial', defaultMultitrial)
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel, @isscalar); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode, @vector);  
addParameter(p, 'plotm', defaultPlotm, @isscalar); 

parse(p, varargin{:});

subject = p.Results.subject;
task = p.Results.task;
BP = p.Results.BP;
cat = p.Results.cat;
multitrial = p.Results.multitrial;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;

%groups = {'V1', 'V2', 'O', 'P', 'F'};
%% Import data
[X, dataset] = import_preproc_data('subject',subject,'cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

chan_name = dataset.chan_name;
chan_group = dataset.group;
groups = dataset.groups;
populations.V1 = dataset.V1;
populations.V2 = dataset.V2;
populations.Others = dataset.other;
populations.Face = dataset.Face;
% Add populations Place
[nchans, nobs, ntrials] = size(X);

%% Modeling whole epoched data

% VAR model

[VARmodel, VARmoest] = VARmodeling(X, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial);
% SS model

tic
[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, 'multitrial', multitrial);
toc

%% Sliding Pairwise GC effect size

F = sliding_ss_to_pwcgc(SSmodel, nchans);
F(isnan(F))=0; 

%% Compute average pGC
fn = fieldnames(populations);

for i=1:numel(fn)
    populations.(fn{i})
end

ngroup = size(groups,1);

mean_F = zeros(ngroup,ngroup);

for i=1:numel(fn)
    for j=1:numel(fn)
        pop_i = double(populations.(fn{i}));
        pop_i = pop_i +1; % add one for matlab compatibility
        pop_j = double(populations.(fn{j}));
        pop_j = pop_j +1;
        mean_F(i,j) = mean(F(pop_i,pop_j), [1,2]);
    end
end

visual_populations = groups;
end