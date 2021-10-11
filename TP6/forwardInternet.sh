#!/bin/bash

# Activation de IP Forwarding
echo "Activation de l'IP Forwarding"
sudo sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

(sysctl net.ipv4.ip_forward | grep -w "1") 1>/dev/null 2>&1 && echo "IP Forwarding enabled" || echo "IP Forwarding disabled"

sudo iptables --table nat --append POSTROUTING --out-interface ens032 -j MASQUERADE