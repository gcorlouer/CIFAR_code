function [X, time] = crop_signal(X, time, varargin)

defaultT_0 = -0.5;
defaultFs = 250;
defaultTmin = 0.075;
defaultTmax = 0.350;

p = inputParser;

addRequired(p, 'X');
addRequired(p, 'time');
addParameter(p, 'tmin', defaultTmin);
addParameter(p, 'tmax', defaultTmax);
addParameter(p, 't_0', defaultT_0);
addParameter(p, 'fs', defaultFs, @isscalar);

parse(p, X, time, varargin{:});


X = p.Results.X;
t_0 = p.Results.t_0;
fs = p.Results.fs;
tmin = p.Results.tmin;
tmax = p.Results.tmax;

sample_min = time_to_sample(tmin, 't_0', t_0, 'fs', fs);
sample_max = time_to_sample(tmax, 't_0', t_0, 'fs', fs);

X = X(:, sample_min:sample_max,:);
time = time(sample_min:sample_max);

end