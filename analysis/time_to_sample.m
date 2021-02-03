function sample = time_to_sample(t,varargin)
% Return sample number given time in seconds

defaultT_0 = -0.5;
defaultFs = 250;

p = inputParser;

addRequired(p, 't');
addParameter(p, 't_0', defaultT_0);
addParameter(p, 'fs', defaultFs, @isscalar);

parse(p, t, varargin{:});

t = p.Results.t;
t_0 = p.Results.t_0;
fs = p.Results.fs;

sample = floor(fs*(t-t_0));
end