%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate mutual information between ROI and rest of system over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans         = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans       = 0;        end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg           = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds             = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile        = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind           = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp         = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('verb',      'var'), verb           = 2;        end % verbosity
if ~exist('fignum',    'var'), fignum         = 1;        end % figure number
if ~exist('figsave',   'var'), figsave        = false;    end % save .fig file(s)?
if ~exist('subject',   'var'), subject        = 'AnRa';                                           end %
if ~exist('task',   'var'),    task           = 'rest_baseline_1';                                end % 
if ~exist('BP',        'var'), BP             = 1;                                                end % BP=-1 for simulated data
if ~exist('ppdir',     'var'), ppdir          = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; end %preproc directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir = test; end

[chans,chanstr,~,ogchans] = select_channels(BP,subject,task,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,task,ppdir,[chans ogchans],tseg,ds,bigfile,1);

xchans = 1:length(chans); % selected channels in X

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

I = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	V = tsdata_to_autocov(W,0);
	I(w) = cov_to_gwiomi(V,{xchans});
	fprintf('I = % 6.4f\n',I(w));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(tsw,I);
	xlim([ts(1) ts(end)]);
	ylabel('mean I/O MI');
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
