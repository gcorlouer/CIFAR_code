function group_i = group2group_i(chan_group, group)
% Return index of channels in specific groups
    switch group 
        case 'V1'
            for i=1:size(chan_group,1)
                group_i(i) = find(ismember(chan_group(i,:), 'V1   ')==1);
            end
        case 'V2'
            for i=1:size(chan_group,1)
            group_i(i) = find(ismember(chan_group, 'V2   ')==1);
            end
        case 'O'
            for i=1:size(chan_group,1)
            group_i(i) = find(ismember(chan_group, 'other')==1);
            end
        case 'P'
            for i=1:size(chan_group,1)
            group_i(i) = find(ismember(chan_group, 'Place')==1);
            end
        case 'F'
            for i=1:size(chan_group,1)
            group_i(i) = find(ismember(chan_group, 'Face ')==1);
            end
    end

end 