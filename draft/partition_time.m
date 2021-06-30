function sample_partition = partition_time(start, varargin)

defaultStop = 1.5;
defaultTau = 0.010;
defaultWindow_size = 0.050;
defaultFs = 250;
defaultT_0 = -0.5;

p = inputParser;

addRequired(p, 'start'); % starting time of partition
addParameter(p, 'tau', defaultTau);
addParameter(p, 't_0', defaultT_0); % starting time of trial
addParameter(p, 'stop', defaultStop);
addParameter(p, 'window_size', defaultWindow_size, @isscalar);
addParameter(p, 'fs', defaultFs);

parse(p, start, varargin{:});

start = p.Results.start;
t_0 = p.Results.t_0;
tau = p.Results.tau;
stop = p.Results.stop;
window_size = p.Results.window_size;
fs = p.Results.fs;

sample_start = time_to_sample(start, 't_0', t_0, 'fs', fs);
sample_window_size = floor(fs * window_size);
sample_stop = time_to_sample(stop, 't_0', t_0, 'fs', fs);
sample_translation = floor(fs * tau);


if tau == 0
    nwindow = 1;
    sample_partition = zeros(nwindow+1,1);
    sample_partition(1) = sample_start;
    sample_partition(2) = sample_stop;
else
    nwindow = floor(2*(sample_stop - sample_start - sample_window_size)/sample_translation + 1);
    sample_partition = zeros(nwindow+1,1);

    for i=1:nwindow+1
        parity = mod(i,2);
        if parity == 1
            sample_partition(i) = sample_start + (i-1)/2*sample_translation;
        else
            sample_partition(i) = sample_start + sample_window_size + (i/2-1)*sample_translation;
        end
    end
end
end