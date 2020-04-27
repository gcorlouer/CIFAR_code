# %% Import modules
import os
import difflib
import re
import mne_bids
import matlab.engine
import mne
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy.io import loadmat
from mne.viz import plot_alignment, snapshot_brain_montage

# %% Pick up dataset
homedir = os.path.expanduser('~')
datadir = os.path.join(homedir,'projects', 'CIFAR', 'data')
os.chdir(datadir)

def CIFAR_filename(sub_id="sub-07", task="rest", run="01", dtype="ieeg",
                   ext=".set"):
    """Return filename given subject id, task, run, and datatype """
    dataset = [sub_id, "freerecall", task, "baseline", f"run-{run}", dtype]
    dataset = "_".join(dataset)
    dataset = dataset + ext
    return dataset


sub_id = "sub-07"
dataset = CIFAR_filename()
subpath = os.path.join(datadir, sub_id, 'ieeg', dataset)
raw_bis = mne.io.read_raw_eeglab(subpath)
