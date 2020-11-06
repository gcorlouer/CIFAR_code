function [F, mean_F, chan_info] = conditional_GC(varargin)

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

chan_type = ['F','P','B'];
%% Import data
[X, dataset] = import_preproc_data('subject',subject,'cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);

ch_names = dataset.chan;
category = dataset.category;

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

%% Compute average pGC

ntype = size(chan_type,2);

mean_F = zeros(ntype,ntype);

for i=1:ntype
    for j=1:ntype
        icat = cat2icat(category, chan_type(i));
        jcat = cat2icat(category, chan_type(j));
        mean_F(i,j) = mean(F(icat,jcat), [1,2]);
    end
end

chan_info.names = ch_names;
chan_info.site = category;
chan_info.ROI = dataset.DK;
chan_info.group = ['F','P','B'];
end