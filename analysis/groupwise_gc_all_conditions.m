%% 

% subjects  {'AnRa',  'AnRi',  'ArLa',  'BeFe',  'DiAs',  'FaWa',  'JuRo',
% 'NeLa', 'SoGi'}

%% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

%%

ncat = 11;
ggc_analysis_test
TE_rest = fgroup_TE;
ncat = 12;
ggc_analysis_test
TE_face = fgroup_TE;
ncat = 13;
ggc_analysis_test
TE_place = fgroup_TE;

%% 

M = cat(2, TE_rest, TE_face, TE_place);
max_TE = max(M, [],'all');
clims = [0 max_TE];
population = channel_to_population;
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,1)
plot_pcgc(TE_rest, clims, fn_pop)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,2)
plot_pcgc(TE_face, clims, fn_pop)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{13}];
subplot(2,2,3)
plot_pcgc(TE_place, clims, fn_pop)
title(plot_title)