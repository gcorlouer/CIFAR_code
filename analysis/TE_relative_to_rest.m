ncat = 11; 
ggc_analysis_test;
fgroup_TE_face = fgroup_TE;
agroup_TE_face = agroup_TE;

ncat = 10; 
ggc_analysis_test;
fgroup_TE_rest = fgroup_TE;
agroup_TE_rest = agroup_TE;

fgroup_TE_rel = fgroup_TE_face - fgroup_TE_rest;
agroup_TE_rel = agroup_TE_face - agroup_TE_rest;

maxf = max(fgroup_TE_rel, [], 'all');
maxa = max(agroup_TE_rel, [], 'all');

%% 
clims = [0 maxf];
plot_title = ['Transfer entropy relative to rest'];  
plot_pcgc(fgroup_TE_rel, clims, fn_pop)
title(plot_title)
%% 
clims = [0 maxf];
plot_title = ['Transfer entropy relative to rest'];  
plot_pcgc(agroup_TE_rel, clims, fn_DK)
title(plot_title)