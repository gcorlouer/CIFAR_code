% Compare GC with respect to rest

TE_rest = GC_to_TE(F_rest, fs);
TE_face = GC_to_TE(F_face, fs);
TE_place = GC_to_TE(F_place, fs);

%% Plot GC
step_window = 10;
fs = 500;
state = 'Rest';

subplot(3,1,1)
plot_sliding_GC(TE_rest, state, step_window, fs)
subplot(3,1,2)

state = 'Face';
plot_sliding_GC(TE_face, state, step_window, fs)

subplot(3,1,3)
state = 'Place';
plot_sliding_GC(TE_place, state, step_window, fs)
%% 
step_window = 10;
fs = 500;
state = 'Rest';

plot_sliding_GC(TE_rest, state, step_window, fs)

%%

state = 'Face';
plot_sliding_GC(TE_face, state, step_window, fs)

%% 

state = 'Place';
plot_sliding_GC(TE_place, state, step_window, fs)

%% 

state = 'Face relative to rest';
TE_rel = TE_face - TE_rest;

plot_sliding_GC(TE_rel, state, step_window, fs)

%%


state = 'Place relative to rest';
TE_rel = TE_place - TE_rest;

plot_sliding_GC(TE_rel, state, step_window, fs)

