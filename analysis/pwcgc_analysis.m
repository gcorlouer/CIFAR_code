function [F, mean_F, populations] = pwcgc_analysis(varargin)

defaultSubject = 'DiAs';
defaultState = 'Face';
defaultMultitrial = true;
defaultFs = 500;
defaultMosel = 1;
defaultMomax = 30;
defaultMoregmode = 'OLS';
defaultPlotm = 1;

p = inputParser;

addParameter(p, 'subject', defaultSubject)
addParameter(p, 'state', defaultState)
addParameter(p, 'multitrial', defaultMultitrial)
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'mosel', defaultMosel); % selected model order: 1 - AIC, 2 - BIC, 3 - HQC, 4 - LRT
addParameter(p, 'momax', defaultMomax, @isscalar);
addParameter(p, 'moregmode', defaultMoregmode);  
addParameter(p, 'plotm', defaultPlotm, @isscalar); 

parse(p, varargin{:});

subject = p.Results.subject;
state = p.Results.state;
multitrial = p.Results.multitrial;
mosel = p.Results.mosel;
momax = p.Results.momax;
moregmode = p.Results.moregmode;
plotm = p.Results.plotm;
%% Load data

datadir = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets', 'preproc');
fname = [subject, '_', state, '_visual_HFB.mat'];
fpath = fullfile(datadir, fname);

dataset = load(fpath);

X = dataset.data;
populations = dataset.populations;

[nchans, nobs, ntrials] = size(X);

%% Modeling whole epoched data

% VAR model

[VARmodel, VARmoest] = VARmodeling(X, 'momax', momax, 'mosel', mosel, ...
'multitrial', multitrial, 'moregmode', moregmode);

% SS model


[SSmodel, SSmoest] = SSmodeling(X, 'mosel', mosel, ... 
    'multitrial', multitrial, 'moregmode', moregmode);


%% Compute pairwise GC

F = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);

F(isnan(F))=0; 
%% Average over populations

fn = fieldnames(populations);

ngroup = size(populations,1);

mean_F = zeros(ngroup,ngroup);

for i=1:numel(fn)
    for j=1:numel(fn)
        pop_i = double(populations.(fn{i}));        
        pop_j = double(populations.(fn{j}));        
        mean_F(i,j) = mean(F(pop_i,pop_j), [1,2]);
    end
end
mean_F(isnan(mean_F))=0;
end