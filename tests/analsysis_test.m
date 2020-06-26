x% This script is the pipeline for one subject 

% TODO: 

% Some errors: 
% Warning : DARE WARNING: large relative residual = 2.364349e-05 ????

%% Parameters


% Filtering

if ~exist('filterOrder', 'var') filterOrder = 100; end 
if ~exist('fcut1','var') fcut1 = 60; end
if ~exist('fcut2','var') fcut2 = 80; end
if ~exist('fstop1','var') fstop1 = 57; end % Stopband attenuation
if ~exist('fstop2','var') fstop2 = 82; end
if ~exist('fs','var') fs = 500;  end
if ~exist('fn','var') fn  = fs/2; end % Nyquist
if ~exist('f','var') f = [0 fstop1 fcut1 fcut2 fstop2 fn]/fn; end % Bandpass frequency with attenuation
if ~exist('a','var') a = [0 0 1 1 0 0]; end % Filter moving average components
if ~exist('w','var') w   = [700 1 700]; end % Weights of the filter 
if ~exist('fbin','var') fbin = 1024; end% Number of frequency bins
if ~exist('Band','var') Band = [fcut1 fcut2]; end

% Epoching 

if ~exist('trange','var') trange = [10 80]; end % Time series range
if ~exist('wsize','var') wsize = [0 10]; end % Epoch size
if ~exist('wstep','var') wstep = 5; end % Step between epochs
if ~exist('multitrial','var') multitrial = true; end

% ROI select for dFC

if ~exist('nROI','var') nROI = 2; end % Number of ROI to pick for analysis
if ~exist('inter','var') inter = false; end % Inter or intra relation for dFC analysis

%% Import data

[fname, fpath, dataset] = CIFAR_filename('preproc', false, ...
    'subject','JuRo'); 
datapath = fullfile('~','projects','CIFAR','data_fun', ... 
    'JuRo_freerecall_rest_baseline_1_preprocessed_BP_montage_pick.mat');
dataset = load(datapath);
EEG = pop_loadset(fname, fpath);
X = double(dataset.data);
EEG.data = X ;

%% Envelope extraction

% Bandpass filter
bpFilt   = firgr(filterOrder, f, a, w, 'minphase');

% Magnitude response
hfvt = fvtool(bpFilt,'Fs', fs,...
              'MagnitudeDisplay', 'Magnitude (dB)',...
              'legend','on');
legend(hfvt,'Min Phase');

% Impulse response
fvtool(bpFilt, 'Fs', fs, ...
              'Analysis', 'Impulse', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');
          
% Extract envelope from hilbert transform on filtered data
[envelope, tsdata_filt] = tsdata2env(X, bpFilt);

srange = 1000:5000; chanum= 3;
plot_envelope(tsdata_filt,envelope,srange, chanum, fs)

% Assign in new EEG structure
EEG_envelope = EEG;
EEG_envelope.data = envelope;

EEG_filt = EEG;
EEG_filt.data = tsdata_filt;

%title: 60-80 Hz envelope


plot_envelope(tsdata_filt,envelope,trange, chanum, fs)

%% Pick chans and envelope

% trange = [10 40];

EEG_envelope = EEG;
EEG_envelope.data = envelope;

EEG_filt = EEG;
EEG_filt.data = tsdata_filt;

EEG_filt = pop_select(EEG_filt, 'time', trange);
EEG_envelope = pop_select(EEG_envelope, 'time', trange);
EEG = pop_select(EEG, 'time', trange);

%% Epoching 

outEEG_env = eeg_regepochs(EEG_envelope, 'recurrence', wstep, 'limits', wsize); % Epoch envelope
epochEEG_filt = eeg_regepochs(EEG_filt, 'recurrence', wstep, 'limits', wsize); % Epoch filtered data
epochEEG = eeg_regepochs(EEG, 'recurrence', wstep, 'limits', wsize); % Epoch initial data

% Extract epoched time series
epochedEnvelope = double(outEEG_env.data); 
epochedTsdata_filt = double(epochEEG_filt.data);
epochX =double(epochEEG.data);

%% Save epoch data

save('epoched_data.mat', 'epochedEnvelope', 'epochX' )

%% VAR modeling envelope

tic 
[VARmodel, VARmoest] = VARmodeling(epochedEnvelope, 'momax', 30, 'mosel', 4, 'multitrial', multitrial);
toc

%% VAR model ECoG

tic 
[VARmodel_ecog, VARmoest_ecog] = VARmodeling(epochX, 'momax', 30, 'mosel', 4, 'multitrial', multitrial);
toc


%% SS Envelope

tic
[SSmodel_envelope, moest_envelope] = SSmodeling(epochedEnvelope, 'mosel', 4, 'multitrial', multitrial);
toc

%% SS ECoG

tic
[SSmodel_ecog, moest_envelope] = SSmodeling(epochX, 'mosel', 4, 'multitrial', multitrial);
toc


%% 

save('VAR.mat', 'VARmodel', 'VARmoest', 'VARmodel_ecog', 'VARmoest_ecog')
save('SSmodel.mat', 'SSmodel_envelope', 'moest_envelope','SSmodel_ecog', 'moest_envelope')

%% Directed funcitonal connectivity (DFC) 


% New channel indexes (for reduced time series)
ichan1 = 1:10;
ichan2 = 11:20;


% DFC on Envelope
[DFC_env, sDFC_env, mDFC_env] = directFC(SSmodel_envelope, ichan1, ichan2, Band, ...
    'multitrial', multitrial, 'inter', true, 'temporal', true, 'ichan', ichan2);

% DFC on ECoG

[DFC_ecog, sDFC_ecog, mDFC_ecog] = directFC(SSmodel_ecog, ichan1, ichan2, Band, ...
    'multitrial', multitrial, 'inter', true, 'temporal', false, 'ichan', ichan2);

% Pairwise CGC



% Plot DFC of ECoG and envelope for multitrial data

% hold on
% plot(DFC_env)
% plot(DFC_ecog)
% legend('Envelope', 'ECoG')
% xlabel('time (sec)')
% ylabel('MVGC')
% DFC_title = ['comparison of DFC on HFB envelope with signal ROI', ...
%     num2str(ROIs(1)), '-', num2str(ROIs(2))];
% title(DFC_title)
% hold off

%% SS GC between channels

F = ss_to_pwcgc(SSmodel_ecog.A, SSmodel_ecog.C, SSmodel_ecog.K, SSmodel_ecog.V);

f = ss_to_spwcgc(SSmodel_envelope.A, SSmodel_envelope.C, SSmodel_envelope.K, SSmodel_envelope.V, fbin);

Fint = bandlimit(f,3);

%% VAR GC: Nope
% 
% tstats    = 'dual';  % test statistic ('single', 'dual' or 'both')
% alpha     = 0.05;    % significance level for Granger casuality significance test
% mhtc      = 'FDR';   % multiple hypothesis test correction (see routine 'significance')
% regmode   = 'LWR';
% 
% [F,stats] = var_to_pwcgc(VARmodel.A,VARmodel.V,tstats, epochX, regmode);
% 
% sigF  = significance(stats.(tstats).F.pval, alpha,mhtc);
% sigLR = significance(stats.(tstats).LR.pval,alpha,mhtc);
% 
% f = var_to_spwcgc(VARmodel_ecog.A, VARmodel_ecog.V, VARmodel_ecog.fres);

%Fint = bandlimit(f,3); % integrate spectral MVGCs (frequency is dimension 3 of CPSD array

%% Plot GC 

plot_gc({F,Fint},{'PWCGC (envelope)','PWCGC (ecog)'},[],[],0);
