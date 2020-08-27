function F = multi_ss_to_pwcgc(SSmodel, nchans, multitrial)

if nargin<3, multitrial = true; end

if multitrial==true
    F = ss_to_pwcgc(SSmodel.A, SSmodel.C, SSmodel.K, SSmodel.V);
else
    ntrials=size(SSmodel,2);
    F = zeros(nchans,nchans,ntrials);
    for iepoch=1:ntrials
        F(:,:,iepoch) = ss_to_pwcgc(SSmodel(iepoch).A, SSmodel(iepoch).C, ... 
            SSmodel(iepoch).K, SSmodel(iepoch).V);
    end
end
