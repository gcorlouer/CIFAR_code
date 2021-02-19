function F = sliding_ss_to_pwcgc(SSmodel, nchan)

nwin = size(SSmodel,2);

F = zeros(nchan,nchan,nwin);
for w=1:nwin
    F(:,:,w) = ss_to_pwcgc(SSmodel(w).A, ... 
        SSmodel(w).C, SSmodel(w).K, SSmodel(w).V);
end
