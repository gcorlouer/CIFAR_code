%% Load data

EEG = cf_read_data(cohort_path, "proc", proc,"condition", condition, "run", run);

%% Plot with EEGlab

pop_eegplot(EEG)
%%
