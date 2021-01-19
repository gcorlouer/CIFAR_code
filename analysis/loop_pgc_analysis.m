%% 
ncat = 3;
population = {'V1', 'Face'};
npop = size(population,2);
TE_cat = zeros(npop,npop,ncat);
for i=1:ncat
    ncat = i; pgc_analysis_test; TE_cat(:,:,i)=TE;
end

%% Plot
clims = [0 0.4];
for i=1:ncat
    subplot(2,2,i)
    plot_pcgc(TE_cat(:,:,i), clims, population')
end
%% Plot Face relative to rest
clims = [0 0.3];
TE_rel = TE_cat(:,:,2)- TE_cat(:,:,1);
plot_pcgc(TE_cat(:,:,i), clims, population')