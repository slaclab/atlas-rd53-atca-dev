# atlas-rd53-atca-dev/firmware/targets/RceDpm/DpmRudpNode

<!--- ######################################################## -->

### Python to set the RCE IP address register

Requires RCE IP address register to be set after DHCP (not included in kernel).
This is typically done using a startup python script like this ...

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

<!--- ######################################################## -->

### Application Register Space Mapping:
0xA0000000:0xA000FFFF = https://github.com/slaclab/surf/blob/master/python/surf/ethernet/udp/_UdpEngine.py
0xA0010000:0xA001FFFF = https://github.com/slaclab/surf/blob/master/python/surf/protocols/rssi/_RssiCore.py (client)
0xA0020000:0xA002FFFF = https://github.com/slaclab/surf/blob/master/python/surf/protocols/rssi/_RssiCore.py (server)

<!--- ######################################################## -->

### How to setup the RUDP connection on the Client Side

After the `RCE IP address register` is set, set the `ServerRemotePort` and `ServerRemoteIp` that the Client will route to:

https://github.com/slaclab/surf/blob/master/python/surf/ethernet/udp/_UdpEngine.py#L70-L102

<!--- ######################################################## -->

### How to setup the RUDP connection on the Server Side

After the `RCE IP address register` is set, no other register are required to setup the server's RUDP connection

<!--- ######################################################## -->

### DMA Mapping:
DMA[0] = RUDP Client
DMA[1] = RUDP Server
DMA[2] = Loopback

<!--- ######################################################## -->
