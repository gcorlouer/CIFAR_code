function sliding_ts = slide_window(X, varargin)
%TODO: create time sample converstion.

defaultStep_window = 10; % 20 ms at 500 Hz
defaultWindow_size = 20;

p = inputParser;

addRequired(p,'X');
addParameter(p, 'step_window', defaultStep_window, @isscalar);
addParameter(p, 'window_size', defaultWindow_size, @isscalar);

parse(p, X, varargin{:});

X = p.Results.X;
step_window = p.Results.step_window;
window_size = p.Results.window_size;

[nchan, nobs, N] = size(X);

nwin = floor((nobs - window_size + 1 + step_window)/step_window);

sliding_ts = zeros(nchan, window_size, N, nwin);

for itrial = 1:N
    for i=1:nwin
        start = 1 + (i-1)*step_window;
        stop = window_size + start -1;
        sliding_ts(:,:,itrial,i) = X(:, start:stop,itrial);
    end
end

