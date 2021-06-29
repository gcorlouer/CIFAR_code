function cnorm = running_LZc(X, maxq)
if nargin < 2 || isempty(maxq), maxq = 1; end 
[nchan, nobs, ntrials] = size(X);
c      = zeros(nchan, ntrials, nobs,maxq);             % complexities of x
crnd   = zeros(nchan, ntrials, nobs,maxq);             % random string complexities
qtiles = cell(maxq,1);                       % quantiles

for ichan = 1:nchan
    for itrial=1:ntrials
        x = squeeze(X(ichan,:,itrial));
        x = x';
        for q = 1:maxq                         % for each quantisation
            fprintf('processing qauntisation %d of %d... ',q,maxq);
            d = q+1;                           % alphabet size = number of quantiles + 1
            [s,qtiles{q}] = LZc_quantise(x,q); % quantise noise sequence by q quantiles; store quantiles
            c(ichan, itrial,:, q) = LZc(s,d);               % calculate "running" LZ complexity (i.e., for all sequence lengths to maximum)
            crnd(ichan, itrial, :, q) = LZc_crand(1:nobs,d);   % load random string mean complexities from file
            fprintf('done\n');
        end
    end
end
    cnorm = c./crnd;                       % complexities normalised by mean complexity of random strings of same length and alphabet size

end