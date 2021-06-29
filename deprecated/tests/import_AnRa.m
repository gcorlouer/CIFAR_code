fpath = '/home/guime/CIFAR_data/iEEG_10/subjects/AnRa/EEGLAB_datasets/preproc/AnRa_freerecall_stimuli_1_preprocessed_lnrmv.set';
EEG = pop_loadset(fpath);
pop_eegplot(EEG)