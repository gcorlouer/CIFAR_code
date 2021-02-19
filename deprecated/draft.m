%% Parameters 

% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end
if ~exist('BP','var') BP = false; end % Bipolar montage
if ~exist('cat','var') state = 'Place'; end %  'Rest', 'Face' or 'Place'

% Modeling
if ~exist('multitrial', 'var') multitrial = true; end 
if ~exist('mosel', 'var') mosel = 1; end % Select model order 1: AIC, 2: BIC, 3: HQC, 4: LRT
if ~exist('momax', 'var') momax = 10; end % Max model order 
if ~exist('regmode', 'var') regmode = 'OLS'; end % OLS or LWR

% Statistics
if ~exist('alpha', 'var') alpha = 0.05; end
if ~exist('mhtc', 'var') mhtc = 'FDRD'; end % multiple hypothesis testing correction
if ~exist('nperms', 'var') nperms = 110; end %  

%% 

state = {'Face','Place','Rest'};
populations = {'V1', 'V2', 'P','F'};
npop = size(populations,2);

nstate = size(state,2);
GC = zeros(npop,npop,nstate);

for i=1:nstate
    
    [F(:,:,i), mean_F(:,:,i), populations] = pwcgc_analysis('state', state{i}, 'multitrial', ... 
        multitrial, 'momax', 30, 'mosel', mosel, 'multitrial', multitrial, 'moregmode', regmode);
end

GC = mean_F;
pGC = F;
nchan = size(pGC,1);

%% Plot GC
fs = 500; % Sampling rate
scale = 1/fs;
bits = 1/log(2); % convert to bits
GC_baseline = GC(:,:,3);
for i=1:npop
    for j=1:npop
        for k=1:nstate
               GC_rel(i,j,k) = (GC(i,j,k)-GC_baseline(i,j));
        end
    end
end

GC_rel_scale = GC_rel*fs*bits;
maxGC = max(GC_rel_scale,[], 'all');
clims = [0 0.8];
for i=1:2
    subplot(2,2,i)
    plot_pcgc(GC_rel_scale(:,:,i), clims, populations')
    title(['Relative GC, ', state{i}, ' trials'])
end
GC_baseline_scale = GC_baseline*fs*bits;
clims = [0 0.7];
subplot(2,2,3)
plot_pcgc(GC_baseline_scale, clims, populations')
title(['GC baseline, ', state{3}])

%% Plot pGC 

fs = 500; % Sampling rate
scale = 1/fs;
bits = 1/log(2); % convert to bits
pGC_baseline = pGC(:,:,3);
for i=1:nchan
    for j=1:nchan
        for k=1:nstate
               pGC_rel(i,j,k) = (pGC(i,j,k)-pGC_baseline(i,j));
        end
    end
end

pGC_rel_scale = pGC_rel*fs*bits;
maxpGC = max(pGC_rel_scale,[], 'all');
clims = [0 1.5];
for i=1:2
    subplot(2,2,i)
    plot_pcgc(pGC_rel_scale(:,:,i), clims)
    title(['Relative GC, ', state{i}, ' trials'])
end
pGC_baseline_scale = pGC_baseline*fs*bits;
clims = [0 1];
subplot(2,2,3)
plot_pcgc(pGC_baseline_scale, clims, chan_group(:,1))
title(['GC baseline, ', state{3}])

