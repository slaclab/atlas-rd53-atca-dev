# Update (03JULY2019)

We are able to get the ILA core to show up on the XVC but not the IBERT core.  We are still looking into this.  While we are working on getting the IBERT core to show up on the XVC, use (unfortunately) the USB JTAG dongles to do the IBERT testing for now.

# dpm-remote-ibert-tester

Here's how I propose we do the IBERT for 8 RCEs on the COB without JTAG dongles:

In our SURF FW library, we have  a "AXI Stream to JTAG Core" module:

https://github.com/slaclab/surf/blob/master/protocols/jtag/README.md
<!--- https://github.com/slaclab/surf/blob/AxiStreamDmaV2-update/protocols/jtag/README.md --->

In another FW library, we have a UDP wrapper for this "AXI Stream to JTAG Core" module:

https://github.com/slaclab/xvc-udp-debug-bridge/blob/master/README.md

Here's how we can connect the DPM's user UDP interface to the XVC UDP Debug Bridge:

https://github.com/slaclab/dpm-remote-ibert-tester/blob/master/firmware/targets/DpmRemoteIbertTester/hdl/DpmRemoteIbertTester.vhd

The PS is very simple.  The only thing that the PS needs to do is write the IP address to RceEthernetReg.ipAddr @ address=0xB000001C after the DHCP IP address assignment is made. 

https://github.com/slaclab/rce-gen3-fw-lib/blob/pre-release/RceEthernet/rtl/RceEthernetReg.vhd#L177

All other SW runs on the host PC.

Note: In proto-DUNE and HPS, RceEthernetReg.ipAddr was set by the high level SW (see URL below). 

https://github.com/slaclab/proto-dune/blob/master/software/protoDUNE/deviceLib/RceCommon.cpp#L100

# Python to set the RCE IP address register

```python
import os
import mmap
import struct
import socket

# Memory map the ETH DMA device
fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(fd, 0x100, offset=0xB0000000)

# Get the local host IP address
hostIP = socket.gethostname()
hostIP = hostIP.replace("."," ").split()
for i in range(4):
    hostIP[i] = int(hostIP[i])

# Set the IP address
mem.seek(0x1C)
mem.write(bytes(hostIP))

# Close open devices
mem.close()
os.close(fd)
```
