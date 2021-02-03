%% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

%%

ncat = 11;
pgc_functional_population
TE_rest = TE;
sig_rest = sig;
ncat = 12;
pgc_functional_population
TE_face = TE;
sig_face = sig;
ncat = 13;
pgc_functional_population
TE_place = TE;
sig_place = sig;

%% Plot TE effect size

M = cat(2, TE_rest, TE_face, TE_place);
max_TE = max(M, [],'all');
clims = [0 max_TE];
population = channel_to_population;
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,1)
plot_pcgc(TE_rest, clims, channel_to_population)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,2)
plot_pcgc(TE_face, clims, channel_to_population)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{13}];
subplot(2,2,3)
plot_pcgc(TE_place, clims, channel_to_population)
title(plot_title)

%% Plot significance 

M = cat(2, TE_rest, TE_face, TE_place);
clims = [0 1];
population = channel_to_population;
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,1)
plot_pcgc(sig_rest, clims, channel_to_population)
title(plot_title)
clims = [0 1];
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,2)
plot_pcgc(sig_face, clims, channel_to_population)
title(plot_title)
clims = [0 1];
plot_title = ['Transfer entropy ', fn{13}];
subplot(2,2,3)
plot_pcgc(sig_place, clims, channel_to_population)
title(plot_title)