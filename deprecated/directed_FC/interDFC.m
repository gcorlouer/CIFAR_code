function [DFC, mDFC] = interDFC(SSmodel, ichan1, ichan2, multitrial)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute directed functional connectivity on a sliding window according to
% diferent mode of connectivity (inter, intra and pairwise channel)
%%% Input parameters: 
% - SSmodel : State space model  (envelope or ECoG) on slided time series.
%             SSmodel is a structure
%             with fields : A,V,C,K, model order and spectral radius
% - ichan     : selected paired channel for DFC
% 
%%% Output 
%
% - DFC: directed functional connectivity on slided window
% - mDFC: mean directed functional connectivity along sliding window
%
% TODO
% Condition on other channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if multitrial == true
    DFC = ss_to_mvgc(SSmodel.A, SSmodel.C, ...
        SSmodel.K, SSmodel.V, ichan1, ichan2);
    mDFC = DFC;
else
    nepoch = size(SSmodel, 2);
    for w = 1:nepoch
        % GC of the envelope between 2 ROIs 
        DFC(w) = ss_to_mvgc(SSmodel(w).A, SSmodel(w).C, ...
            SSmodel(w).K, SSmodel(w).V, ichan1, ichan2);
    end
    
    mDFC = mean(DFC(w),2);
end

end