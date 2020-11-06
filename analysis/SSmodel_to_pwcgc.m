function F = SSmodel_to_pwcgc(SSmodel, nchan)

F = zeros(nchan,nchan);
F = ss_to_pwcgc(SSmodel.A, ... 
        SSmodel.C, SSmodel.K, SSmodel.V);
end