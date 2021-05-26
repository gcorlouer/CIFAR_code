function [F, sig] = ts_to_var_mvgc(X, ROI_idx, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate groupwise conditional Granger causality (GC) from VAR model with
% given model order. 
% ROI_idx is a structure containing indices of channels within ROIs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultMorder = 5;
defaultRegmode = 'OLS';
defaultAlpha = 0.05;
defaultMhtc = 'FDRD';
defaultLR = true;
p = inputParser;

addRequired(p,'X');
addRequired(p,'ROI_idx');
addParameter(p, 'regmode', defaultRegmode);  
addParameter(p, 'morder', defaultMorder);  
addParameter(p, 'alpha', defaultAlpha)
addParameter(p, 'mhtc', defaultMhtc)
addParameter(p, 'LR', defaultLR)

parse(p, X, ROI_idx, varargin{:});

X = p.Results.X;
ROI_idx = p.Results.ROI_idx;
morder = p.Results.morder;
regmode = p.Results.regmode;
alpha = p.Results.alpha;
mhtc =  p.Results.mhtc;
LR = p.Results.LR;

%% VAR modeling

VAR = ts_to_var_parameters(X, 'morder', morder, 'regmode', regmode);
disp(VAR.info)
%% MVGC

V = VAR.V;
A = VAR.A;

fn = fieldnames(ROI_idx);
nROI = numel(fn);
F = zeros(nROI, nROI);
sig = zeros(nROI, nROI);
for i=1:nROI
    for j=1:nROI
        if i==j
            F(i,j)=0;
        else 
            x = ROI_idx.(fn{i});
            y = ROI_idx.(fn{j});
            [F(i,j),pval] = var_to_mvgc(A,V,x,y,X,regmode);
            % Chose statistical test
                if LR == true
                    stats = pval.LR;
                else 
                    stats = pval.FT;
                end
            % Return statistical significance
            sig(i,j) = significance(stats,alpha,mhtc);
        end
    end
end
end