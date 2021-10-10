#!/bin/bash

# Desactiver les services de cloud-init 
echo "Desactiver les services de cloud-init"
( ( ( echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg ) && sudo apt-get purge cloud-init -y ) && sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/ ) 1>/dev/null 2>&1 && echo "cloud-init removed" || echo "cloud-init not removed"

# Changer le domaine de la machine
echo "Changer le domaine de la machine"
( sudo hostnamectl set-hostname "$HOSTNAME".tpadmin.local ) 1>/dev/null 2>&1 && echo "Hostname changed to $HOSTNAME.tpadmin.local" || echo "Hostname not changed"

# Installation du serveur DHCP 
echo "Installation du serveur DHCP"
( ( sudo apt update && sudo apt upgrade -y ) 1>/dev/null 2>&1 && sudo apt install isc-dhcp-server -y ) 1>/dev/null 2>&1 && echo "isc-dhcp-server installed" || echo "isc-dhcp-server not installed"

# Changement de la configuration reseau 
echo " Changement de la configuration reseau"
( echo "
network:
    ethernets:
        ens32:
            dhcp4: true
        ens33:
            addresses: 
            -   192.168.100.1/24
            gateway4: 192.168.100.1            
    version: 2
" | sudo tee /etc/netplan/50-cloud-init.yaml && sudo netplan apply && sudo systemctl restart systemd-networkd ) 1>/dev/null 2>&1 && echo "Network configuration good" || echo "Error in the network configuration"

# Configuration du serveur DHCP
echo "Configuration du serveur DHCP"
( sudo mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak ) 1>/dev/null 2>&1 && echo "Backup DHCP configuration is good" || echo "Error in the backup DHCP configuration"

( echo '
default-lease-time 120;
max-lease-time 600;
authoritative; 
option broadcast-address 192.168.100.255; 
option domain-name "tpadmin.local"; 
subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.240; 
    option routers 192.168.100.1; 
    option domain-name-servers 192.168.100.1; 
}
' | sudo tee /etc/dhcp/dhcpd.conf ) 1>/dev/null 2>&1 && echo "DHCP configuration is good" || echo "Error in the DHCP configuration"

( echo '
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd s config file (default: /etc/dhcp/dhcpd.conf).
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd s PID file (default: /var/run/dhcpd.pid).
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#       Don t use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#       Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACESv4="ens33"
INTERFACESv6=""
' | sudo tee /etc/default/isc-dhcp-server && sudo dhcpd -t && sudo systemctl restart isc-dhcp-server ) 1>/dev/null 2>&1 && echo "DHCP Server listen configuration is good" || echo "Error in the DHCP Server listen configuration"
sleep 10
( sudo ps -aux | cut -d: -f1 | grep -w "dhcpd" ) 1>/dev/null 2>&1  && echo "DHCP Server is on" || echo "DHCP Server is off"


