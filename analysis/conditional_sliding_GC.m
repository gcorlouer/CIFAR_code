function [F, mean_F, chan_info] = conditional_sliding_GC(varargin)

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