function [S,freq,fbin] = tsdata2cpsd(X, varargin)

[nchan,nobs, ntrial] = size(X);

defaultMtaper = true;
defaultFs = 500;
defaultPlotm = true;
defaultNwin = [];
defaultFbin = [];
defaulSparms = [];
defaultAutospec = true;
defaultVerb = 0 ;
defaultLogplt = true;
defaultOverlap = [];

p = inputParser;

addRequired(p,'X');
addParameter(p, 'mtaper', defaultMtaper, @islogical);
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'plotm', defaultPlotm, @islogical);
addParameter(p, 'nwin', defaultNwin, @isvector);
addParameter(p, 'fbin', defaultFbin);
addParameter(p, 'sparms', defaulSparms);
addParameter(p, 'autospec', defaultAutospec, @islogical);
addParameter(p, 'verb', defaultVerb);
addParameter(p, 'logplt', defaultLogplt, @islogical);
addParameter(p, 'overlap', defaultOverlap);

parse(p, X, varargin{:});

[S,freq,fbin] = tsdata_to_cpsd(p.Results.X,p.Results.fs, ... 
    p.Results.nwin, [], p.Results.fbin, p.Results.autospec, p.Results.verb);

if p.Results.plotm 
    plot_autocpsd(S,freq,p.Results.fs,nchan, p.Results.logplt);
else
    
end

end

