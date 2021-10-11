#!/bin/bash

# Activation de IP Forwarding
echo "Activation de l'IP Forwarding"
sudo sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

(sysctl net.ipv4.ip_forward | grep -w "1") 1>/dev/null 2>&1 && echo "IP Forwarding enabled" || echo "IP Forwarding disabled"

#  Autoriser la traduction d’adresse source
echo "Autoriser la traduction d’adresse source"
VARINTERFACE1=$(ip a | grep -w 2 | cut -d: -f2)
sudo iptables --table nat --append POSTROUTING --out-interface "$VARINTERFACE1" -j MASQUERADE