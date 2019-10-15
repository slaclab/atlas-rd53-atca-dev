# atlas-rd53-atca-dev

<!--- ######################################################## -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```
$ git-lfs version
git-lfs/2.1.1
```

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/atlas-rd53-atca-dev
```

<!--- ######################################################## -->

# How to build the simple SMGII example firmware

1) Setup Xilinx licensing (if you are on the SLAC network)
```
$ source atlas-rd53-atca-dev/firmware/setup_env_slac.sh
```

2) Go to the target directory:
```
$ cd atlas-rd53-atca-dev/firmware/targets/AtlasAtcaLinkAggSgmii/
```

Optional#1: Build the firmware in batch mode
```
$ make
```

Optional#2: Build the firmware in GUI mode
```
$ make gui
```

<!--- ######################################################## -->

# How to install the Rogue With Anaconda

- Rogue is the `rapid prototyping` software used at SLAC

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ######################################################## -->

# How to reprogram the FPGA PROM via Rogue software

```
# Go to software directory
$ cd atlas-rd53-atca-dev/software

# Activate Rogue conda Environment 
$ source /path/to/my/anaconda3/etc/profile.d/conda.sh

# Setup the Python Environment
$ source setup_env.sh

# Reprogram the FPGA
$ python3 scripts/updateFpgaProm.py --ip <List of IP addresses> --mcs <PATH_TO_MCS_FILE>
```

<!--- ######################################################## -->

# How to run the Rogue PyQT GUI

```
# Go to software directory
$ cd atlas-rd53-atca-dev/software

# Activate Rogue conda Environment 
$ source /path/to/my/anaconda3/etc/profile.d/conda.sh

# Setup the Python Environment
$ source setup_env.sh

# Launch the PyQT GUI
$ python scripts/gui.py --ip <List of IP addresses>
```

<!--- ######################################################## -->
