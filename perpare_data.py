# %% Import modules
import os
import csv
import re
import mne_bids
import matlab.engine
import mne
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy.io import loadmat
from mne.viz import plot_alignment, snapshot_brain_montage
# %%
%matplotlib auto
homedir = os.path.expanduser('~')
subjectdir = os.path.join(homedir, 'projects', 'CIFAR', 'data_fun', 'iEEG_10', 'subjects')
os.chdir(subjectdir)
nsub = len(os.listdir(subjectdir))
#change name of subdir
lisub = [f"{i:02}" for i in range(nsub)]
print(lisub)
# Reneame directrories
for idx, sub in enumerate(os.listdir(subjectdir)):
    isub = f"{lisub[idx]}"
    newsub = f"sub-{isub}"
    print(newsub)
    os.rename(src=sub, dst=newsub)
# rename brain and anatomical datasets
for sub in os.listdir(subjectdir):
    os.chdir(subjectdir)
    print(sub)
    os.chdir(sub)
    os.rename(src='brain', dst = 'anat')
    os.rename(src= 'EEGLAB_datasets', dst = 'ieeg')
    print(os.listdir())
#%% Mapping old subject name new subject names
subname_map = {}
os.getcwd()
for sub in os.listdir(subjectdir):
    datadir = os.path.join(sub, 'ieeg', 'raw_signal')
    list_dataset = os.listdir(datadir)
    dataset = list_dataset[0]
    oldsubname = dataset[0:4]
    subname_map[f'{oldsubname}'] = sub

subname_map
subname_mapfile = os.path.join(homedir, 'projects', 'CIFAR', 'data_fun', 'submap.csv')
datafun_dir = os.path.join(homedir, 'projects', 'CIFAR', 'data_fun')
os.chdir(datafun_dir)

with open('submap.csv','w') as f:
    w = csv.DictWriter(f, subname_map.keys())
    w.writeheader()
    w.writerow(subname_map)

#%% change dataset names
#XXXX_freerecall_rest_baseline_1_preprocessed --> sub-##_newtask_run_(raw?)
oldsubname = dataset[0:3]

# Use Regular expression
sub_rest_test = 'XXXX_freerecall_rest_baseline_1_preprocessed'
sub_stim_test = 'XXXX_freerecall_stimuli_1_preprocessed'


# Copy bp montage in derivative folder
