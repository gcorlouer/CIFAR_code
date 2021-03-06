%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slide state space modeling along a sliding window on CIFAR, simulated or
% envelope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('schans',    'var'),       schans         = -6 ;                                             end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'),       badchans       = 0 ;                                               end % bad channels (empty for none)
if ~exist('tseg',      'var'),       tseg           = [10 30];                                          end % start/end times (empty for entire time series)
if ~exist('ds',        'var'),       ds             = 1;                                                end % downsample factor
if ~exist('bigfile',   'var'),       bigfile        = false;                                            end % data file too large to read into memory
if ~exist('wind',      'var'),       wind           = [5 0.1];                                         end % window width and slide time (secs)
if ~exist('tstamp',    'var'),       tstamp         = 'mid';                                            end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'),       fres           = 1024;                                             end % number of freq bins
if ~exist('data',      'var'),       data           = 'CIF';                                            end % 
if ~exist('subject',   'var'),       subject        = 'AnRa';                                           end %
if ~exist('task',   'var'),          task           = 'rest_baseline_1';                                end % 
if ~exist('BP',        'var'),       BP             = 1;                                                end % BP=-1 for simulated data
if ~exist('ppdir',     'var'),       ppdir          = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; end %preproc directory
if ~exist('fig_path_tail',   'var'), fig_path_tail  = '/figures/stationarity/ssmodeling/';              end %path 2 save figure
if ~exist('iband',   'var'),         iband          = 2;                                                end
if ~exist('band_low',   'var'),      band_low       = 60;                                               end
if ~exist('band_size',   'var'),     band_size      = 20;                                               end
if ~exist('nband',   'var'),         nband          =   5;                                                    end
if ~exist('filt_order',   'var'),    filt_order     = 138;                                              end
if ~exist('simorder',  'var'),       simorder       = 5;                                                end % morder for simulation
if ~exist('specrad',   'var'),       specrad        = 0.98;                                             end
if ~exist('nobs',   'var'),          nobs           = 100000;                                           end
if ~exist('fs',   'var'),            fs             = 500 ;                                             end
if ~exist('g',   'var'),             g              = [] ;                                              end
if ~exist('w',   'var'),             w              = [] ;                                              end
if ~exist('w',   'var'),             nchanSim       = 10;                                               end
if ~exist('ntrials',   'var'),       ntrials        = 1 ;                                               end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import data
cd(cfsubdir)

if data=='CIF'
    [X, ts, EEG, filepath,filename,chanstr] = import_ecogdata(BP, subject, task, schans, tseg, badchans,ds, ppdir);
    [nchans,nobs]                           = size(X);
    fig_filetail=[filename,'_BP_',num2str(BP),'_ROI_',num2str(-schans),'_','_wind_',num2str(wind(1)),'s_',ppdir(1:7)];
elseif data=='sim' %simulate VAR model
    [X,ts,var_coef,corr_res]                = var_sim(nchanSim, simorder);
    fig_filetail=['varsim_morder_',num2str(simorder),'_numchan_',num2str(numchan)];
end
cd(CIFAR_root)

%% Extract envelope at a given frequency band

[envelope_band,band] = tsdata2HFB(X,fs,band_low,band_size,nband,filt_order);
envelope_fband       = envelope_band(:,:,iband);
    
%% Slice time series and envelope into time windows

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind);

%% Run state space model spectral GC between specific frequency bands

ptic('**** Spectral GC on windowed time series ')
fband          = [band_low+iband*band_size band_low+(iband+1)*band_size];
[wsgc,wsgcint] = sliding_ts2sgc_ss(X,nwin,nsobs,nwobs,fband);
ptoc;

%% Run state space model temporal GC on the envelope

ptic('**** SS model on windowed envelope ')
wtgc = sliding_ts2tgc_ss(envelope_fband,nwin,nsobs,nwobs); %NEED to test if work
ptoc; 

%% Test significant Granger Causal connection

% p=10;
% alpha=0.05;
% correction= 'FDR';
% w=1;
% 
% epval = mvgc_pval(squeeze(wsgcint(w,:,:)),p,nobs,1,nchans,nchans);
% esig  = significance(pval,alpha,correction);
% 
% tspval = mvgc_pval(squeeze(wtgc(w,:,:)),p,nobs,1,nchans,nchans);
% tssig  = significance(pval,alpha,correction);

%% Plot GC

% etgc=squeeze(wsgcint(1,:,:));
% tgc=squeeze(wtgc(1,:,:));
% 
% wetgc  = zeros(nchans,nchans*nwin);
% wtstgc = zeros(nchans,nchans*nwin);   
% 
% wetgc(:,1:nchans)  = squeeze(wsgcint(1,:,:));
% wtstgc(:,1:nchans) = squeeze(wtgc(1,:,:));
% 
% for w=1:nwin-1
%     wetgc(:,w*nchans+1:(w+1)*nchans) = squeeze(wsgcint(w,:,:));
%     wtstgc(:,w*nchans+1:(w+1)*nchans) = squeeze(wtgc(w,:,:));
% end

mean_etgc = squeeze(mean(wtgc, 1));
mean_tstgc =  squeeze(mean(wsgcint, 1));
F = {mean_etgc, mean_tstgc};

envelopeTitle = ['GC ', num2str(fband(1)),  'Hz envelope'];
spectralTitle = 'Spectral GC';
ptitle = {envelopeTitle, spectralTitle };
plot_gc(F,ptitle)

% %% Plot heamap
% 
% etgc=squeeze(wsgcint(1,:,:));
% tgc=squeeze(wtgc(1,:,:));
% 
% wetgc  = zeros(nchans,nchans*nwin);
% wtstgc = zeros(nchans,nchans*nwin);
% 
% % wetgc  = reshape(wsgcint,nchans,nchans*nwin);
% % wtstgc = reshape(wtgc,nchans,nchans*nwin);
% 
% wetgc(:,1:nchans)  = squeeze(wsgcint(1,:,:));
% wtstgc(:,1:nchans) = squeeze(wtgc(1,:,:));
% 
% for w=1:nwin-1
%     wetgc(:,w*nchans+1:(w+1)*nchans) = squeeze(wsgcint(w,:,:));
%     wtstgc(:,w*nchans+1:(w+1)*nchans) = squeeze(wtgc(w,:,:));
% end
% 
% heatmap(wetgc);
% figure
% heatmap(wtstgc);
% 
 
%% Save results in mat file

% pathname   = [pwd,'/matplotlib_plot'];
% e_tgc_mat  = 'gc_envelope.mat';
% tgc_mat    = 'gc.mat';
