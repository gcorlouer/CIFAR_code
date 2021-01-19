% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

%%

ncat = 10;
ggc_analysis_test
TE_rest = fgroup_TE;
ncat = 11;
ggc_analysis_test
TE_face = fgroup_TE;
ncat = 12;
ggc_analysis_test
TE_place = fgroup_TE;

%% 

max_TE = max(TE_face, [],'all');
clims = [0 max_TE];
population = channel_to_population;
plot_title = ['Transfer entropy ', fn{10}];
subplot(2,2,1)
plot_pcgc(TE_rest, clims, fn_pop)
title(plot_title)
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,2)
plot_pcgc(TE_face, clims, fn_pop)
title(plot_title)
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,3)
plot_pcgc(TE_place, clims, fn_pop)
title(plot_title)