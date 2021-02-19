function F = sliding_ss_to_mvgc(SSmodel, category, chan_type)

if nargin < 3, chan_type = ['F','P','B']; end

ncat = size(chan_type,2);
nwin = size(SSmodel,2);

F = zeros(ncat,ncat,nwin);
for i=1:size(chan_type,2)
    for j=1:size(chan_type,2)
        for w=1:nwin
            if i==j
                F(i,j,w)=0;
            else
                itarget_chan =  cat2icat(category, chan_type(i));
                isource_chan =  cat2icat(category, chan_type(j));
                F(i, j, w) = ss_to_mvgc(SSmodel(w).A, ... 
                    SSmodel(w).C, SSmodel(w).K, SSmodel(w).V, ... 
        itarget_chan, isource_chan);
            end
        end
     end
end