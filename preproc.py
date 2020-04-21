# %% Import modules
import matlab.engine
import startup
import os
import mne_bids
from pathlib import Path, PurePath
import mne
import matplotlib.pyplot as plt
import pandas as pd
# Enable the table_schema option in pandas,
# data-explorer makes this snippet available with the `dx` prefix:
pd.options.display.html.table_schema = True
pd.options.display.max_rows = None

# %% import data
Path.cwd()
%matplotlib auto
dataset = 'AnRa_freerecall_rest_baseline_1_preprocessed.set'
dpath = PurePath('data', 'iEEG_10', 'subjects', 'AnRa', 'EEGLAB_datasets', 'raw_signal')
fpath = dpath_raw.joinpath(dataset)
raw = mne.io.read_raw_eeglab(fpath, preload=True)
raw.info  # does not give npts

# %% Check Data
raw.plot(duration=200, n_channels=30, scalings=5e-4, color='b')

# Define channel pick_types

# drop bad channels


# %% Bipolar montage or ICA
# %% Drop bad channels
# ToDo plot cpsd
badchan_dpath = PurePath('data', 'subjects', 'S01', 'prep_badchans')
badchan_fname = 'sub-01_freerecall_rest_run_1_BP_badchan.fif'
badchan_fpath = badchan_dpath.joinpath(badchan_fname)
# visualise data and identify bad channels
raw.plot(duration=200, n_channels=30, scalings=5e-4, color='b')
raw.info['bads']
#raw.save(badchan_fpath, overwrite=True)
# %% detrend
raw_bad = raw.copy()
raw_bad.info
raw_bad = mne.io.Raw(badchan_fpath, preload=True)
raw_bad.info
bads = raw_bad.info['bads']
raw_bad = raw_bad.pick_types(exclude=['TRIG'])
raw_bad = raw_bad.drop_channels('TRIG')
print(raw_bad.times)
times = raw_bad.time_as_index(200)
print(times)
