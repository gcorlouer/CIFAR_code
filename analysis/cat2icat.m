function icat = cat2icat(category, type)
icat = find(ismember(category(:,1), type)==1);
end 