function [MI, stats] = multi_info(X, varargin)

defaultMultitrial = true;
defaultConnectivity = 'intra';
defaultGroup = {1:size(X,1)};
defaultChans1 = {1:size(X,1)-1};
defaultChans2 = {size(X,1)};

p = inputParser;

addRequired(p,'X');
addParameter(p, 'connectivity', defaultConnectivity);
addParameter(p,'group', defaultGroup);
addParameter(p, 'multitrial', defaultMultitrial, @islogical);
addParameter(p,'chans1',defaultChans1);
addParameter(p,'chans2', defaultChans2);

parse(p, X, varargin{:});

multitrial = p.Results.multitrial;
X = p.Results.X;
group = p.Results.group;
connectivity = p.Results.connectivity;
chans1 = p.Results.chans1;
chans2 = p.Results.chans2;

switch connectivity
    case 'intra'
        [MI, stats] = multi_intra_info(X, group, multitrial);
    case 'extra'
        [MI, stats] = multi_io_info(X, group, multitrial);
    case 'mutual'
        [MI, stats] = multi_mutual_info(X, chans1, chans2, multitrial);
end
end

function [MVI, stats] = multi_intra_info(X, group, multitrial)

[nchan, nobs, ntrials] = size(X);

if multitrial == true 
    V = tsdata_to_autocov(X,0);
    [MVI, stats] = cov_to_gwgmi(V,group, nobs, ntrials);
else
    
    for itrial=1:ntrials
        V(:,:,itrial) = tsdata_to_autocov(X(:,:,itrial),0);
        [MVI(:,:,itrial), stats(:,:,itrial)] = cov_to_gwgmi(V(:,:,itrial),group, nobs, 1);
    end
end
end

function [MVI, stats] = multi_io_info(X, group, multitrial)

[nchan, nobs, ntrials] = size(X);

if multitrial == true 
    V = tsdata_to_autocov(X,0);
    [MVI, stats] = cov_to_gwiomi(V,group, nobs, ntrials);
else
    
    for itrial=1:ntrials
        V(:,:,itrial) = tsdata_to_autocov(X(:,:,itrial),0);
        [MVI(:,:,itrial), stats(:,:,itrial)] = cov_to_gwiomi(V(:,:,itrial),group, nobs, 1);
    end
end
end

function [MI, stats] = multi_mutual_info(X, chans1, chans2, multitrial)
[nchan, nobs, ntrials] = size(X);

if multitrial == true 
    V = tsdata_to_autocov(X,0);
    [MI, stats] = cov_to_mvmi(V, chans1, chans2, nobs, ntrials);
else
    for itrial=1:ntrials
        V(:,:,itrial) = tsdata_to_autocov(X(:,:,itrial),0);
        [MI(:,:,itrial), stats(:,:,itrial)] = cov_to_mvmi(V(:,:,itrial), chans1, chans2, nobs, 1);
    end
end
end