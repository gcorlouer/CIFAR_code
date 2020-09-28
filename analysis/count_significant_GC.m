function nsig = count_significant_GC(F, i_to, i_from)

% Count the number of significant GC connection from one chanel to a group
nsig = 0;  
for i=1:size(i_to,1)
    for j =1:size(i_from,1)
        if F(i_to(i), i_from(j)) == 1
            nsig = nsig+1;
        else 
            nsig = nsig; 
        end
    end
end 
