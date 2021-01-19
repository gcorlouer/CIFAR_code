% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

%%

ncat = 10;
pgc_analysis_test
TE_rest = TE;
ncat = 11;
pgc_analysis_test
TE_face = TE;
ncat = 12;
pgc_analysis_test
TE_place = TE;

%% 

max_TE = max(TE_face, [],'all');
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{10}];
subplot(2,2,1)
plot_pcgc(TE_rest, clims, population)
title(plot_title)
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,2)
plot_pcgc(TE_face, clims, population)
title(plot_title)
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,3)
plot_pcgc(TE_place, clims, population)
title(plot_title)