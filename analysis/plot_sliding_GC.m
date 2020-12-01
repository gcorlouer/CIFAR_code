function plot_sliding_GC(F, state, step_window, fs)

nwin = size(F,3);
time_step = step_window/fs;
duration = time_step*(nwin-1);
time = 0:time_step:duration;
for i=1:2
    for j=1:2
        if i==j
            continue 
        else    
        plot(time, squeeze(F(i,j,:)), 'DisplayName', sprintf('%i to %i ', j, i))
        xlabel('Time (s)')
        ylabel('TE (bits/s)')
        hold on
        end
    end
end
legend('show')
title(['Transfer entropy ', state]);