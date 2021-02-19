%% 

% subjects  {'AnRa',  'AnRi',  'ArLa',  'BeFe',  'DiAs',  'FaWa',  'JuRo',
% 'NeLa', 'SoGi'}

%% Input data
if ~exist('subject', 'var') subject = 'DiAs'; end

%%
% 
ncat = 11;
groupwise_gc_one_condition
TE_rest = fgroup_TE;
ncat = 12;
groupwise_gc_one_condition
TE_face = fgroup_TE;
ncat = 13;
groupwise_gc_one_condition
TE_place = fgroup_TE;

%% 

M = cat(2, TE_rest, TE_face, TE_place);
max_TE = max(M, [],'all');
clims = [0 max_TE];
group = population;
% group = cell(npop,1);
% for i =1:npop
%     group{i} = fn_pop{i}(8:end);
% end
plot_title = ['Transfer entropy ', fn{11}];
subplot(2,2,1)
plot_pcgc(TE_rest, clims, group)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{12}];
subplot(2,2,2)
plot_pcgc(TE_face, clims, group)
title(plot_title)
clims = [0 max_TE];
plot_title = ['Transfer entropy ', fn{13}];
subplot(2,2,3)
plot_pcgc(TE_place, clims, group)
title(plot_title)