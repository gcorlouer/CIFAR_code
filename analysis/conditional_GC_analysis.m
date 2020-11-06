%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('task', 'var') task = 'stimuli_1'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') cat = 'Place'; end %  'Rest', 'Face' or 'Place'

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 1; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('regmode', 'var') regmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end %  

chan_type = ['F','P','O'];
%% 

cat = {'Face','Place','Rest'};
task = {'stimuli_1','stimuli_1','rest_baseline_1'};
ntype = size(chan_type,2);

GC = zeros(ntype,ntype,ntype);

for i=1:ntype
    
    [F(:,:,i), mean_F(:,:,i),chan_info] = conditional_GC('cat', cat{i}, 'multitrial', ... 
        multitrial, 'task', task{i}, 'BP', BP,'momax', 30, 'mosel', mosel, ...
        'multitrial', multitrial);
end

GC = mean_F;
%% Plot
fs = 250; % Sampling rate
scale = 1/fs;
bits = 1/log(2); % convert to bits
GC_baseline = GC(:,:,3);
for i=1:3
    for j=1:3
        for k=1:3
               GC_rel(i,j,k) = (GC(i,j,k)-GC_baseline(i,j));
        end
    end
end

GC_rel_scale = GC_rel*fs*bits;
maxGC = max(GC_rel_scale,[], 'all');
clims = [0 0.8];
for i=1:2
    subplot(2,2,i)
    plot_pcgc(GC_rel_scale(:,:,i), clims, chan_type')
    title(['Relative GC, ', cat{i}, ' trials'])
end
GC_baseline_scale = GC_baseline*fs*bits;
clims = [0 0.7];
subplot(2,2,3)
plot_pcgc(GC_baseline_scale, clims, chan_type')
title(['GC baseline, ', cat{3}])

%% Plot GC baseline 
GC_baseline_scale = GC_baseline/scale;
maxGC_baseline_scale  = max(GC_baseline_scale,[], 'all');
clims = [0 0.6];
plot_pcgc(GC_baseline_scale, clims, chan_type')

%% Plot
fs = 250; % Sampling rate
scale = 1/fs; 
GC_scale = GC/scale;
GC_baseline = GC_scale(:,:,3);
maxGC = max(GC_scale,[], 'all');
clims = [0 0.8];
for i=1:2
    subplot(2,2,i)
    plot_pcgc(GC_scale(:,:,i), clims, chan_type')
    title(['GC ', cat{i}, ' trials (bits/s)'])
end
clims = [0 0.4];
subplot(2,2,3)
plot_pcgc(GC_scale(:,:,3), clims, chan_type')
title(['GC ', cat{3}, ' trials (bits/s)'])

%% Plot GC relative to Place
GC_Frel = GC(:,:,1) - GC(:,:,2);
GC_Frel = GC_Frel*fs*bits;
plot_pcgc(GC_Frel, clims, chan_type')