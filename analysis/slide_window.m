function sliding_ts = slide_window(X, varargin)
%TODO: create time sample converstion.

defaultStart = 0.075;
defaultStop = 1.5;
defaultTau = 0.010;
defaultWindow_size = 0.050;
defaultFs = 250;
defaultT_0 = -0.5;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'start', defaultStart);
addParameter(p, 'tau', defaultTau);
addParameter(p, 't_0', defaultT_0); % starting time of trial
addParameter(p, 'stop', defaultStop);
addParameter(p, 'window_size', defaultWindow_size, @isscalar);
addParameter(p, 'fs', defaultFs);

parse(p, X, varargin{:});

X = p.Results.X;

start = p.Results.start;
t_0 = p.Results.t_0;
tau = p.Results.tau;
stop = p.Results.stop;
window_size = p.Results.window_size;
fs = p.Results.fs;

sample_start = time_to_sample(start, 't_0', t_0, 'fs', fs);
window_sample_size = floor(fs * window_size);
sample_stop = time_to_sample(stop, 't_0', t_0, 'fs', fs);
sample_translation = floor(fs * tau);

if tau == 0 
    error('No time translation means no sliding window')
end

[nchan, nobs, N] = size(X);

nwindow = floor((sample_stop - window_sample_size - sample_start)/sample_translation);

sliding_ts = zeros(nchan, window_sample_size, N, nwindow);

for itrial = 1:N
    for i=1:nwindow
        window_start = sample_start + i*sample_translation;
        window_stop = window_sample_size + window_start -1;
        sliding_ts(:,:,itrial,i) = X(:, window_start:window_stop,itrial);
    end
end

