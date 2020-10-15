function [F_gp, sig_gp] = SSmodel_to_ggc(X, SSmodel, multitrial, category, varargin)

defaultAlpha = 0.05;
defaultNperms = 100; 
defaultMhtc = 'FDRD';
defaultMultitrial = false;

p = inputParser;

addRequired(p, 'X');
addRequired(p, 'category');
addRequired(p, 'SSmodel');
addParameter(p, 'multitrial',defaultMultitrial);
addParameter(p, 'alpha', defaultAlpha, @isscalar);
addParameter(p, 'nperms', defaultNperms, @isscalar);
addParameter(p, 'mhtc', defaultMhtc);

parse(p, X, SSmodel, category, varargin{:});

X = p.Results.X;
SSmodel = p.Results.SSmodel;
category =  p.Results.category;
alpha = p.Results.alpha;
nperms = p.Results.nperms;
mhtc = p.Results.mhtc;

chan_type = ['F','P','B'];
ncat = size(chan_type,2);

if multitrial == true
    F_gp = zeros(ncat,ncat);
    sig_gp = zeros(ncat,ncat);


    for i=1:size(chan_type,2)
        for j=1:size(chan_type,2)
            itarget_chan =  cat2icat(category, chan_type(i));
            isource_chan =  cat2icat(category, chan_type(j));
            if i==j
                [F_gp(i,j), sig_gp(i,j)] = deal(0,0);
            else
                tic
                [F_gp(i,j), sig_gp(i,j)] = SSmodel_to_mvgc_permtest(X, ... 
                    SSmodel, itarget_chan, isource_chan,  'alpha', alpha, 'nperms', nperms, 'mhtc', mhtc);
                toc
            end
        end
    end
else
    ntrials = size(X,3);

    F_gp = zeros(ncat,ncat, ntrials);
    sig_gp = zeros(ncat,ncat, ntrials);

    for i=1:size(chan_type,2)
        for j=1:size(chan_type,2)
            for iepoch=1:ntrials
                itarget_chan =  cat2icat(category, chan_type(i));
                isource_chan =  cat2icat(category, chan_type(j));
                if i==j
                    [F_gp(i,j,iepoch), sig_gp(i,j,iepoch)] = deal(0,0);
                else
                    tic
                    [F_gp(i,j,iepoch), sig_gp(i,j,iepoch)] = SSmodel_to_mvgc_permtest(X(:,:,iepoch), ... 
                        SSmodel(iepoch), itarget_chan, isource_chan, ... 
                        'alpha', alpha, 'nperms', nperms, 'mhtc', mhtc);
                    toc
                end
            end
        end
    end
end