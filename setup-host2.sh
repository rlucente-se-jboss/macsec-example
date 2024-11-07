#!/usr/bin/env bash

. $(dirname $0)/demo.conf

[[ $EUID -ne 0 ]] && exit_on_error "Must run as root"

dnf -y install container-tools tcpdump

#
# configure macsec0 interface
#
ip link add link $ETHDEV_2 macsec0 type macsec encrypt on
ip macsec add macsec0 rx port 1 address $MAC_1
ip macsec add macsec0 tx sa 0 pn 1 on key 00 $TX_KEY_2
ip macsec add macsec0 rx port 1 address $MAC_1 sa 0 pn 1 on key 01 $TX_KEY_1

ip link set macsec0 up
ip addr add $HOST_2/24 dev macsec0

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

#
# Create quadlet for MACsec secured webserver
#
cat > /etc/containers/systemd/macsec-webserver.container <<EOF
[Unit]
Description=A web server bound to MACsec device

[Container]
Image=docker.io/library/httpd:latest
ContainerName=webserver
PublishPort=$HOST_2:8080:80

[Service]
Restart=always

[Install]
WantedBy=default.target
EOF

#
# Launch the MACsec secured webserver
#
systemctl daemon-reload
systemctl start macsec-webserver
