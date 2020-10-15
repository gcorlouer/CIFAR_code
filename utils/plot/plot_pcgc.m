function plot_pcgc(F, category)
n = size(category,1);
colormap(flipud(bone));
imagesc(F);
axis('square');
xlabel('from');
ylabel('to');
set(gca,'XTick',1:n);
set(gca,'XTickLabel',category);
set(gca,'YTick',1:n);
set(gca,'YTickLabel',category);
colorbar
