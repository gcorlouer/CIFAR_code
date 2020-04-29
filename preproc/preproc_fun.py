# %% Import modules
import os
import re
import mne_bids
import matlab.engine
import mne
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy.io import loadmat
from mne.viz import plot_alignment, snapshot_brain_montage

from pathlib import Path, PurePath, PosixPath

# Enable the table_schema option in pandas,
# data-explorer makes this snippet available with the `dx` prefix:
pd.options.display.html.table_schema = True
pd.options.display.max_rows = None

# %%
Path.cwd()
%matplotlib auto
homedir = os.path.expanduser('~')
subjectdir = os.path.join(homedir, 'projects', 'CIFAR', 'source_data', 'iEEG_10', 'subjects')
sub_id = "AnRa"
task = "freerecall_rest_baseline"
run = "1"
data_type = "preprocessed"
dataset_list = [sub_id, task, run, data_type]
dataset = "_".join(dataset_list)
fname_suffix = "set"
fname = ".".join((dataset, fname_suffix))
datapath = os.path.join(subjectdir, sub_id, 'EEGLAB_datasets', 'raw_signal')
fpath = os.path.join(datapath, fname)
raw = mne.io.read_raw_eeglab(fpath, preload=True)

# %% Configure channels
raw.plot(duration=200, n_channels=30, scalings=5e-4, color='b')
raw_test = raw.copy()
raw_test.set_channel_types()
chan_names = raw_test.ch_names
ch_dict = raw_test.info["chs"]
ch_dig = raw_test.info["dig"]
chan_names
misc_chans = ["TRIG", "P3", "F7", "F3", "T3", "T5"]
pattern = 'RDh'
hippocamp_chan = [chan for chan in chan_names if re.search(pattern, chan)]
raw_test.info
ch_dict[8]

for name in chan_names:
    raw_test.set_channel_types({name: 'ecog'})
raw_test.set_channel_types({'ECG': 'ecg'})
for name in misc_chans:
    raw_test.set_channel_types({name: 'misc'})

raw_test.info
raw_test.plot(duration=200, n_channels=30, scalings=5e-4, color='b')

# %% Get SUMA mapping

sub_id = "AnRa"
anatpath = os.path.join(subjectdir, sub_id, 'brain')
elecfile = 'elecinfo.mat'
elecpath = os.path.join(anatpath, elecfile)
elec = loadmat(elecpath)
elec.keys()
elec['electrode_name']
elec['ROI_DK'] = elec['ROI_DK'].T
euclid = ['X', 'Y', 'Z']
bad_keys = ['__header__', '__version__', '__globals__', 'coord']

for idx, item in enumerate(euclid):
    elec[item] = elec['coord'][:, idx]

for item in bad_keys:
    del elec[item]

for item in elec.keys():
    elec[item] = np.concatenate(elec[item])
    for i in range(elec[item].size):
        elec[item][i] = elec[item][i][0]
elec
# Convert to dataframe

dfelec = pd.DataFrame.from_dict(elec)
electrodes_info = 'electrodes_info.csv'
elecinfopath = os.path.join(anatpath, electrodes_info)
dfelec.to_csv(elecinfopath)
df = pd.read_csv(elecinfopath)
df
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
