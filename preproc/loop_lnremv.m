subjects = {'AnRa', 'AnRi', 'ArLa', 'BeFe','DiAs', 'FaWa','JuRo', 'NeLa', 'SoGi'};
tasks = {'rest_baseline_1', 'rest_baseline_2', 'stimuli_1','stimuli_2'};
montage = 'raw_signal';
BP = false;

for i= 8:size(subjects,2)
    subject = subjects{i};
    path = fullfile('~','CIFAR_data', 'iEEG_10', 'subjects', subject, 'EEGLAB_datasets');
    cd(path)
    mkdir 'preproc'
    for j = 1:size(tasks,2)
        task = tasks{j};
        lnremv;
    end
end
