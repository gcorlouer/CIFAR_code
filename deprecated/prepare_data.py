# %% Import modules
import os
import shutil
import difflib
import re
import csv
import mne_bids
import matlab.engine
import mne
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy.io import loadmat
from mne.viz import plot_alignment, snapshot_brain_montage
from pathlib import Path, PurePath
from mne_bids import write_raw_bids, make_bids_basename, read_raw_bids
from mne_bids.utils import print_dir_tree

pd.options.display.html.table_schema = True
pd.options.display.max_rows = None

# ToDO
#  SUMA mapping
# Make subject map

# %% Pick up dataset

homedir = Path.home()
CIFAR_dir = homedir.joinpath('projects', 'CIFAR')
datadir = homedir.joinpath('projects', 'CIFAR', 'source_data')
subjectdir = datadir.joinpath('iEEG_10', 'subjects')
datafun_dir = CIFAR_dir.joinpath('data_fun')

os.chdir(subjectdir)

def CIFAR_filename(sub_id="sub-07", task="rest", run="01", dtype="ieeg",
                   ext=".set"):
    """Return filename given subject id, task, run, and datatype """
    dataset = [sub_id, "freerecall", task, "baseline", f"run-{run}", dtype]
    dataset = "_".join(dataset)
    dataset = dataset + ext
    return dataset

def CIFAR_srcfilename(sub_id="AnRa", task="rest", run="1", dtype="preprocessed",
                      ext=".set"):
    """Return filename given subject id, task, run, and datatype """
    dataset = [sub_id, "freerecall", task, "baseline", run, dtype]
    dataset = "_".join(dataset)
    dataset = dataset + ext
    return dataset

bids_root = homedir.joinpath('projects', 'CIFAR', 'data_bids')
sub_id = ['AnRa',  'AnRi',  'ArLa',  'BeFe',  'DiAs',  'FaWa',  'JuRo',  'NeLa',  'SoGi']

# %% Create BIDS data

for idx, sub in enumerate(sub_id):
    dataset = CIFAR_srcfilename(sub_id=sub)
    ieeg = subjectdir.joinpath(sub, 'EEGLAB_datasets', 'raw_signal')
    for dataset in os.listdir(ieeg):
        datapath = ieeg.joinpath(dataset)
        if datapath.suffix == '.fdt':
            continue
        else:
            fpath = os.fspath(datapath)
            raw = mne.io.read_raw_eeglab(fpath, preload=False)
            for name in raw.ch_names:
                raw.set_channel_types({name: 'ecog'})
            subject_id = f'0{idx}'
            p = re.compile('rest|stimuli')
            m = p.search(dataset)
            task = m.group()
            p = re.compile('[1-2]')
            m = p.search(dataset)
            run = f'0{m.group()}'
            pre, ext = os.path.splitext(dataset)
            fifname = pre + '.fif'
            fifpath = datafun_dir.joinpath(fifname)
            fifpath = os.fspath(fifname)
            raw.save(fifpath, overwrite=True)
            fifraw = mne.io.read_raw_fif(fifpath)
            bids_basename = make_bids_basename(subject=subject_id,
                                               task=task, run=run)
            write_raw_bids(fifraw, bids_basename, bids_root, overwrite=True)

# %% Anatomical files

for idx, sub in enumerate(sub_id):
    pialsrc = subjectdir.joinpath(sub, 'brain', 'SUMAPialSrf.mat')
    inflasrc = subjectdir.joinpath(sub, 'brain', 'SUMAInflatedSrf.mat')
    pialsrc = os.fspath(pialsrc)
    inflasrc = os.fspath(inflasrc)
    anatpath = bids_root.joinpath(f'sub-0{idx}', 'anat')
    pialdest = anatpath.joinpath('SUMAPialSrf.mat')
    infladest = anatpath.joinpath('SUMAInflatedSrf.mat')
    pialdest = os.fspath(pialdest)
    infladest = os.fspath(infladest)
    shutil.copy(inflasrc, infladest)

#%% SUMA mapping
isub = '8'
sub_id = 'SoGi'
# for idx, sub in enumerate(sub_id):
brainpath = os.path.join(subjectdir, sub_id, 'brain')
elecfile = 'elecinfo.mat'
elecpath = os.path.join(brainpath, elecfile)
elec = loadmat(elecpath)
elec.keys()
elec['electrode_name']
elec['ROI_DK'] = elec['ROI_DK'].T
euclid = ['X', 'Y', 'Z']
bad_keys = ['__header__', '__version__', '__globals__', 'coord']

for idx, item in enumerate(euclid):
    elec[item] = elec['coord'][:, idx]
elec['electrode_name']
for item in bad_keys:
    del elec[item]
for item in elec.keys():
    elec[item] = np.concatenate(elec[item])
    for i in range(elec[item].size):
        elec[item][i] = elec[item][i][0]

#%% Convert to dataframe

dfelec = pd.DataFrame.from_dict(elec, orient='index')
dfelec = dfelec.T
electrodes_info = 'electrodes_info.csv'
anatpath = bids_root.joinpath(f'sub-0{isub}', 'anat')
elecinfopath = os.path.join(anatpath, electrodes_info)
dfelec.to_csv(elecinfopath)

# badshape = ['Brodman', 'ROI_DK', 'electrode_name', 'hemisphere', 'isdepth']
#
# for item in badshape:
#     #elec[item] = elec[item].flatten()
#     elec[item] = np.concatenate(elec[item])
# #badshape = ['electrode_name', 'hemisphere']
#
# for item in badshape:
#     for i in range(elec[item].size):
#         elec[item][i] = elec[item][i][0]
# # save to csv format
# anatpath = bids_root.joinpath(f'sub-0{idx}', 'anat')
# os.chdir(anatpath)
# with open('electrodes_mri.csv', 'w') as f:
#      w = csv.DictWriter(f, elec.keys())
#      w.writeheader()
#      w.writerow(elec)


# t = elec['Brodman'].flatten()
# t = elec['Brodman']
#
# badshape = ['Brodman', 'ROI_DK', 'electrode_name', 'hemisphere', 'isdepth']
#
# for item in badshape:
#     elec[item] = elec[item].flatten()
#
# badshape = ['electrode_name', 'hemisphere']
#
# for item in badshape:
#     for i in range(elec[item].size):
#         elec[item][i] = elec[item][i][0]

# %% Make bids
dataset = 'AnRa_freerecall_rest_baseline_1.set'
bids_root = homedir.joinpath('projects', 'CIFAR', 'data_bids')
subject_id = '01'
p = re.compile('rest|stimuli')
task = p.search(dataset)
task.group()
p = re.compile('[1-2]')
run = p.search(dataset)
run.group()
task = 'rest'
run = '1'

bids_basename = make_bids_basename(subject=subject_id,
                                   task=task, run=run,  suffix='ieeg.fif')
bids_basename
write_raw_bids(raw, bids_basename, bids_root=bids_root)
