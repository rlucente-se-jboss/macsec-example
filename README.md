# WIP use at your own risk

## Setup environment
This was tested using two KVM virtual machines running RHEL 9.4 where
each machine had a single NIC that was connected to the same virtual
network as the other. A user with administrative privileges was created
on each machine (e.g. they are in the `wheel` group).

Make sure that the parameters in the `demo.conf` file match the device
values on each virtual guest. The parameters `ETHDEV_1`, `MAC_1`,
`ETHDEV_2`, and `MAC_2` must be correct for their respective hosts.

Clone or copy this repo to each of the virtual guests. From the host
running the virtual guests, open an ssh session to each virtual guest
and then do the following on both guests.

    cd ~/macsec-example
    sudo ./register-and-update.sh
    sudo reboot

In the terminal window of the first guest,

    cd ~/macsec-example
    sudo ./setup-host1.sh

In the terminal window of the second guest,

    cd ~/macsec-example
    sudo ./setup-host2.sh

## Test the interfaces
There should be a webserver running as a container on each guest that's
bound to the IP address assigned to the macsec0 device. In the terminal
window for the first guest, run the following command to capture packets
on the non-MACsec ethernet interface.

    cd ~/macsec-example
    . demo.conf
    sudo tcpdump -Ai $ETHDEV_1 ether host $MAC_2

In the terminal window of the second guest, request the web page:

    cd ~/macsec-example
    . demo.conf
    curl -s http://$HOSTIP_1:8080

You should see a simple web page returned but on the first guest all
the packets are encrypted according to the 802.1AE protocol.

In the terminal window of the first guest, CTRL-C the tcpdump process
and then run it again on the macsec0 interface.

    cd ~/macsec-example
    sudo tcpdump -Ai macsec0 ether host $MAC_2

In the terminal window of the second guest, request the web page again:

    cd ~/macsec-example
    curl -s http://$HOSTIP_1:8080

You should see a simple web page returned and on the first guest all
the packets are non-encrypted. This should also work in the reverse
direction as well (host1 -> host2).
