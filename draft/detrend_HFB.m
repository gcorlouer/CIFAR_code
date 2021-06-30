function X = detrend_HFB(X, varargin)

defaultDeg_max = 2;
defaultBasis = 'polynomials';
defaultThresh = 5;
defaultNiter = 3;

p = inputParser;

addRequired(p, 'X')
addParameter(p, 'deg_max', defaultDeg_max)
addParameter(p, 'basis', defaultBasis)
addParameter(p, 'thresh', defaultThresh)
addParameter(p, 'niter', defaultNiter)


parse(p, X, varargin{:});

deg_max = p.Results.deg_max;
basis = p.Results.basis;
thresh = p.Results.thresh;
niter = p.Results.niter;
X = p.Results.X;

[n, nobs, ntrials] = size(X);

for j = 1:ntrials
    y(:,:,j) = X(:,:,j)';
end


for i=1:deg_max
    for j = 1:ntrials
        order=i;
        [y(:,:,j),~,~]=nt_detrend(y(:,:,j),order,[],basis,thresh,niter);
    end
end

% Demean data


for j = 1:ntrials
    y(:,:,j)=nt_demean(y(:,:,j),[]);
    X(:,:,j) = y(:,:,j)';
end
end