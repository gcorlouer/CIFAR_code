subjects = {'AnRa', 'AnRi', 'ArLa', 'BeFe','DiAs', 'FaWa','JuRo', 'NeLa', 'SoGi'};
tasks = {'rest_baseline_1', 'rest_baseline_2', 'stimuli_1','stimuli_2'};
deg_max = 2;

nsubjects = size(subjects,2);
ntasks = size(tasks,2);

for i=1:nsubjects
    subject = subjects{i};
    for j=1:ntasks
        task = tasks{j};
        preprocessed_signal = preprocessing('subject', subject, 'task', task, 'deg_max', deg_max);
    end
end