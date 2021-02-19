% gGC script

cat = 'Rest'; 
task = 'rest_baseline_1';
nperms = 1;
groupwise_GC_analysis;
siggp_Rest = sig_gp;
 

cat = 'Place'; 
task = 'stimuli_1';
nperms = 1;
groupwise_GC_analysis;
siggp_Place = sig_gp;


cat = 'Face'; 
task = 'stimuli_1';
nperms = 1;
groupwise_GC_analysis;
siggp_Face = sig_gp;
pGC_Face = pGC_sig; 

%% Plot sig F,P,R

subplot(2,2,1)
plot_pcgc(siggp_Rest, category)
title('GC Rest')
subplot(2,2,2)
plot_pcgc(siggp_Face, category)
title('GC Face')
subplot(2,2,3)
plot_pcgc(siggp_Place, category)
title('GC Place')