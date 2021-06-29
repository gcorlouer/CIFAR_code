for i=1:2
    for j= i+1:3
        F_pair = squeeze(F(i,j,:));
        plot(trial_stamp, F_pair)
        hold on
    end
end
legend()

plot(trial_stamp(1:136), squeeze(F_rest(1,6,1:136)))
hold on 
plot(trial_stamp(1:136), squeeze(F_stim(1,6,1:136)))
legend('rest', 'stim')
xlabel('Time (s)')
ylabel('Pairwise conditional GC')
title('Sliding window analysis of pairwise conditional GC between envelope of V2-MT contact')