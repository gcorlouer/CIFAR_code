function plot_pcgc(F, clims, category)

n = size(category,1);
colormap(flipud(bone));
imagesc(F, clims);
axis('square');
xlabel('from');
ylabel('to');
set(gca,'XTick',1:n);
set(gca,'XTickLabel',category);
set(gca,'YTick',1:n);
set(gca,'YTickLabel',category);
xtickangle(45)
colorbar
