% pGC script

nperms = 100;

cat = 'Rest'; 
task = 'rest_baseline_1';
pairwise_GC_analysis;
sigp_Rest = sig_p;
pGC_Rest = pGC_sig; 

cat = 'Place'; 
task = 'stimuli_1';
pairwise_GC_analysis;
sigp_Place = sig_p;
pGC_Place = pGC_sig; 

cat = 'Face'; 
task = 'stimuli_1';
pairwise_GC_analysis;
sigp_Face = sig_p;
pGC_Face = pGC_sig; 

%% 

subplot(2,2,1)
plot_pcgc(pGC_Rest, chan_type')
title('pGC Rest')
subplot(2,2,2)
plot_pcgc(pGC_Place, chan_type')
title('pGC Place')
subplot(2,2,3)
plot_pcgc(pGC_Face, chan_type')
title('pGC Face')

