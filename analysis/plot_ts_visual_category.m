cat = 'Face'; task = 'stimuli_1';
[Xf, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);
Xf_m = mean(Xf,3);
cat = 'Place'; task = 'stimuli_1';
[Xp, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);
Xp_m = mean(Xp,3);
cat = 'Rest'; task = 'rest_baseline_1';
[Xr, dataset] = import_preproc_data('cat', cat, 'multitrial', multitrial, 'task', task, 'BP', BP);
Xr_m = mean(Xr,3);

subplot(3,1,1)
plot_tsdata(Xf_m)
subplot(3,1,2)
plot_tsdata(Xp_m)
subplot(3,1,3)
plot_tsdata(Xr_m)
