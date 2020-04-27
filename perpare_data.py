# %% Import modules
import os
import shutil
import csv
import re
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
subjectdir
os.chdir(subjectdir)
nsub = len(os.listdir(subjectdir))
#change name of subdir
# lisub = [f"{i:02}" for i in range(nsub)]
# print(lisub)
# # Reneame directrories
# for idx, sub in enumerate(os.listdir(subjectdir)):
#     isub = f"{lisub[idx]}"
#     newsub = f"sub-{isub}"
#     print(newsub)
#     os.rename(src=sub, dst=newsub)
# # rename brain and anatomical datasets
# for sub in os.listdir(subjectdir):
#     os.chdir(subjectdir)
#     print(sub)
#     os.chdir(sub)
#     os.rename(src='brain', dst = 'anat')
#     os.rename(src= 'EEGLAB_datasets', dst = 'ieeg')
#     print(os.listdir())
#%% Mapping old subject name new subject names
# subname_map = {}
# os.getcwd()
# for sub in os.listdir(subjectdir):
#     datadir = os.path.join(sub, 'ieeg', 'raw_signal')
#     list_dataset = os.listdir(datadir)
#     dataset = list_dataset[0]
#     oldsubname = dataset[0:4]
#     subname_map[f'{oldsubname}'] = sub
#
# subname_map
# subname_mapfile = os.path.join(homedir, 'projects', 'CIFAR', 'data_fun', 'submap.csv')
# datafun_dir = os.path.join(homedir, 'projects', 'CIFAR', 'data_fun')
# os.chdir(datafun_dir)
#
# with open('submap.csv','w') as f:
#     w = csv.DictWriter(f, subname_map.keys())
#     w.writeheader()
#     w.writerow(subname_map)

#%% change dataset names
# import map

#XXXX_freerecall_rest_baseline_1_preprocessed --> sub-##_newtask_run_(raw?)
oldsubname = dataset[0:3]

# Use Regular expression : https://docs.python.org/3.8/howto/regex.html#regex-howto
os.getcwd()
for sub in os.listdir():
    rawdir = os.path.join(sub, 'ieeg', 'raw_signal')
    os.chdir(rawdir)
    for dataset in os.listdir():
        p = re.compile(dataset[0:4])
        newdataset = p.sub(sub, dataset)
        p = re.compile('_preprocessed')
        newdataset = p.sub('_ieeg', newdataset)
        p = re.compile('_')
        dsplit = p.split(newdataset)
        nrun = dsplit[-2]
        dsplit[-2] = f'run-0{nrun}'
        newdataset = '_'.join(dsplit)
        os.rename(dataset, newdataset)
    os.chdir(subjectdir)

# Create new structure where to store subject file
new_datadir = os.path.join(homedir, 'projects', 'CIFAR', 'new_data')
os.chdir(new_datadir)

os.chdir(subjectdir)
for sub in os.listdir():
    rawdir = os.path.join(subjectdir, sub, 'ieeg', 'raw_signal')
    os.chdir(rawdir)
    for dataset in os.listdir():
        datadest = os.path.join(new_datadir, sub, 'ieeg')
        shutil.copy(dataset, datadest)
    os.chdir(subjectdir)

for sub in os.listdir(new_datadir):
    os.chdir(sub)
    os.mkdir('anat')
    os.mkdir('ieeg')
    os.chdir(new_datadir)

# Transfer anatomical data:

src_pial = 'SUMAPialSrf.mat'
src_inflated = 'SUMAInflatedSrf.mat'
for sub in os.listdir(new_datadir):
    braindir = os.path.join(subjectdir, sub, 'anat')
    os.chdir(braindir)
    anat_dest = os.path.join(new_datadir, sub, 'anat')
    shutil.copy(src_pial, anat_dest)
    shutil.copy(src_inflated, anat_dest)

# Transfer electrodes info:

src_elec = 'electrodes.mat'
src_SUMAelec = 'SUMAprojectedElectrodes.mat'
for sub in os.listdir(new_datadir):
    braindir = os.path.join(subjectdir, sub, 'anat')
    os.chdir(braindir)
    dest_elec = os.path.join(new_datadir, sub, 'ieeg')
    shutil.copy(src_elec, dest_elec)
    shutil.copy(src_SUMAelec, dest_elec)

# create participant table and data description. In derivativ can also add
# fsaverage bipolar montage derivation. Scripts to plot electrodes and referencing
# should be  stored in the code directory

# Rename all  dataset subjects
os.getcwd()
homedir = os.path.expanduser('~')
datadir = os.path.join(homedir, 'projects', 'CIFAR', 'data')
os.chdir(datadir)

for sub in os.listdir(datadir):
    if sub == "submap.csv":
        continue
    else:
        ieegdir = os.path.join(sub, 'ieeg')
        os.chdir(ieegdir)
        for dataset in os.listdir():
            if dataset[0:3] == "sub":
                newdataset = dataset[0:8]+'r'+dataset[8:]
                os.rename(dataset, newdataset)
            else:
                continue
        os.chdir(datadir)

dataset = "sub-07_feerecall_rest_baseline_run-01_ieeg.set"
dataset[0:8]
dataset[8:]
newdataset = dataset[0:8]+'r'+dataset[8:]
newdataset
suma = "SUMAprojectedElectrodes.mat"

for sub in os.listdir(datadir):
    if sub == "submap.csv":
        continue
    else:
        ieegdir = os.path.join(sub, 'ieeg')
        os.chdir(ieegdir)
        for dataset in os.listdir():
            if dataset[0:3] == "sub":
                print(dataset)
            else:
                continue
        os.chdir(datadir)
os.listdir()
