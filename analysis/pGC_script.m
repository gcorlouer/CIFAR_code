tasks = {'rest_baseline_1','stimuli_1','stimuli_1'};
trial_types = {'Rest','Place', 'Face'};
for i = 1:size(tasks,2)
    task = tasks{i};
    cat = trial_types{i};
    pairwise_GC;
    F_trial(:,:,i) = F;
end

F_max = max(F_trial, [], 'all');
F_trial = F_trial/F_max;
visual_type = cat(:,1);
for i = 1:size(tasks,2)
subplot(2,2,i)
plot_pcgc(F_trial(:,:,i), visual_type')
title(['PWCGC' , trial_types{i}])
end