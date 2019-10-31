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

# Setup Xilinx licensing for Vivado

Use the script to setup Xilinx licensing (if you are on the SLAC network)

```
$ source atlas-rd53-atca-dev/firmware/setup_env_slac.sh
```

<!--- ######################################################## -->

# How to build the ZCU102 LpGBT firmware

Go to the target directory:

```
$ cd atlas-rd53-atca-dev/firmware/targets/XilinxZcu102/XilinxZcu102LpGbt
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

# How to build the KCU105 (RD53 FMC card + Emulation LpGBT) firmware

Go to the target directory:

```
$ cd atlas-rd53-atca-dev/firmware/targets/XilinxKcu105/AtlasRd53FmcXilinxKcu105_EmuLpGbt
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

# How to build the RCE's DPM RUDP Node (includes RUDP client and RUDP server)

Go to the target directory:

```
$ cd atlas-rd53-atca-dev/firmware/targets/RceDpm/DpmRudpNode
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

# How to build the AtlasAtcaLinkAgg (24 mDP RD53 RTM + Emulation LpGBT) firmware

Go to the target directory:

```
$ cd atlas-rd53-atca-dev/firmware/targets/AtlasAtcaLinkAgg/AtlasAtcaLinkAggRd53Rtm_EmuLpGbt
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

# How to build the AtlasAtcaLinkAgg (24 mDP RD53 RTM + backplane ETH to DpmRudpNode) firmware

Go to the target directory:

```
$ cd atlas-rd53-atca-dev/firmware/targets/AtlasAtcaLinkAgg/AtlasAtcaLinkAggRd53Rtm_BackplaneEth
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
