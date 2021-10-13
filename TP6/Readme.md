# TP 6 - Services réseau
***Emile METRAL ICS 3***<br>
***Ecrit avec un clavier en qwerty il se peut qu'il manque des accents***
<br>
## Exercice 3. Installation du serveur DHCP
Scripts de configuration et'installation du serveur DHCP :
```bash
#!/bin/bash

if [ ! -f ~/ISReboot ]
then
    # Desactiver les services de cloud-init
    echo "Desactiver les services de cloud-init"
    ( ( ( echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg ) && sudo apt-get purge cloud-init -y ) && sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/ ) 1>/dev/null 2>&1 && echo "cloud-init removed" || echo "cloud-init not removed"

    # Changer le domaine de la machine
    echo "Changer le domaine de la machine"
    ( sudo hostnamectl set-hostname "$HOSTNAME".tpadmin.local ) 1>/dev/null 2>&1 && echo "Hostname changed to $HOSTNAME.tpadmin.local" || echo "Hostname not changed"

    echo "0" > ~/ISReboot 
    echo "Reboot... run script dhcp after reboot"
    sleep 5
    sudo reboot
fi


# Installation du serveur DHCP 
echo "Installation du serveur DHCP"
( sudo apt update && sudo apt upgrade -y  && sudo apt install isc-dhcp-server -y ) 1>/dev/null 2>&1 && echo "isc-dhcp-server installed" || echo "isc-dhcp-server not installed"

# Changement de la configuration reseau 
echo " Changement de la configuration reseau"
VARINTERFACE1=$(ip a | grep -w 2 | cut -d: -f2)
VARINTERFACE2=$(ip a | grep -w 3 | cut -d: -f2)
VARNETCONF=$(ls /etc/netplan/)
( echo "
network:
    ethernets:
        $VARINTERFACE1:
            dhcp4: true
        $VARINTERFACE2:
            addresses: 
            -   192.168.100.1/24          
    version: 2
" | sudo tee /etc/netplan/"$VARNETCONF" && sudo netplan apply && sudo systemctl restart systemd-networkd ) 1>/dev/null 2>&1 && echo "Network configuration good" || echo "Error in the network configuration"

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

( echo "
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd s config file (default: /etc/dhcp/dhcpd.conf).
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd s PID file (default: /var/run/dhcpd.pid).
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#       Don t use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=\"\"

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#       Separate multiple interfaces with spaces, e.g. \"eth0 eth1\".
INTERFACESv4=\"$VARINTERFACE2\"
INTERFACESv6=\"\"
" | sudo tee /etc/default/isc-dhcp-server && sudo dhcpd -t && sudo systemctl restart isc-dhcp-server ) 1>/dev/null 2>&1 && echo "DHCP Server listen configuration is good" || echo "Error in the DHCP Server listen configuration"
sleep 10
( sudo ps -aux | cut -d: -f1 | grep -w "dhcpd" ) 1>/dev/null 2>&1  && echo "DHCP Server is on" || echo "DHCP Server is off"

rm ~/ISReboot
```

8. Que contient le fichier /var/lib/dhcp/dhcpd.leases sur le serveur, et qu’aﬀicle la commande dhcp-lease-list ?
```
Le fichier contient les logs des allocations d'adresses en cours avec pas mal de details sur les clients dhcp.

La commande mets en forme le fichier precedent et nous permet donc de recuperer les allocations actuelles. 
```

## Exercice 4. Donner un accès à Internet au client
Script de configuration :
```bash
#!/bin/bash

# Activation de IP Forwarding
echo "Activation de l'IP Forwarding"
sudo sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sudo sysctl -p /etc/sysctl.conf

(sysctl net.ipv4.ip_forward | grep -w "1") 1>/dev/null 2>&1 && echo "IP Forwarding enabled" || echo "IP Forwarding disabled"


#  Autoriser la traduction d’adresse source
echo "Autoriser la traduction d’adresse source"
VARINTERFACE1=$(ip a | grep -w 2 | cut -d: -f2)
( sudo iptables --table nat --append POSTROUTING  --out-interface $VARINTERFACE1 -j MASQUERADE ) && echo "Masquerading enabled" || echo "Masquerading disabled"

# Installation de iptables-persistent pour sauvegarder la configuration 
(sudo apt install iptables-persistent -y) 1>/dev/null 2>&1 && echo "iptables-persistent installed" || echo "iptables-persistent not installed"
```

## Exercice 5. Installation du serveur DNS
```bash
#!/bin/bash
( ( sudo apt update && sudo apt upgrade -y ) 1>/dev/null 2>&1 && sudo apt install dnsutils bind9 bind9-doc -y ) 1>/dev/null 2>&1 && echo "Bind9 installed" || echo "Bind9 not installed" 

# Configuration de la zone tpadmin.local
echo "Configuration de la zone tpadmin.local"
( echo "
zone \"tpadmin.local\" IN {
    type master; 
    file \"/etc/bind/db.tpadmin.local\"; 
};" | sudo tee -a /etc/bind/named.conf.local ) 1>/dev/null 2>&1 && echo "DNS configured for tpadmin.local" || echo "DNS configured for tpadmin.local"

sudo cp  /etc/bind/db.local /etc/bind/db.tpadmin.local
sudo sed -i -e 's/localhost/tpadmin.local/g'  /etc/bind/db.tpadmin.local
sudo sed -i -e 's/127.0.0.1/192.168.100.1/g'  /etc/bind/db.tpadmin.local
SERIALLINE=$(sudo sed -n "6 p" /etc/bind/db.tpadmin.local)
sudo sed -i -e "s/$SERIALLINE/                         13102021       ; Serial/g"  /etc/bind/db.tpadmin.local

echo "
zone \"100.168.192.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.192.168.100\";
};" | sudo tee -a /etc/bind/named.conf.local

sudo cp /etc/bind/db.127 /etc/bind/db.192.168.100

sudo sed -i -e 's/localhost/tpadmin.local/g'  /etc/bind/db.192.168.100
sudo sed -i -e 's/127.0.0.1/192.168.100.1/g' /etc/bind/db.192.168.100
sudo sed -i -e 's/1.0.0/1./g' /etc/bind/db.192.168.100
SERIALLINE=$(sudo sed -n "6 p" /etc/bind/db.192.168.100)
sudo sed -i -e "s/$SERIALLINE/                         13102021       ; Serial/g"  /etc/bind/db.192.168.100

named-checkconf /etc/bind/named.conf.local
named-checkzone /etc/bind/tpadmin.local /etc/bind/db.tpadmin.local
named-checkzone 100.168.192.in-addr.arpa /etc/bind/db.192.168.100

sudo sed -i -e 's/#DNS=/DNS=192.168.100.1/g' /etc/systemd/resolved.conf
sudo sed -i -e 's/#FallbackDNS=/FallbackDNS=8.8.8.8/g' /etc/systemd/resolved.conf
sudo sed -i -e 's/#Domains=/Domains=tpadmin.local/g' /etc/systemd/resolved.conf

sudo systemctl restart bind9.service
```

Configuration du client :
```bash
( ( ( echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg ) && sudo apt-get purge cloud-init -y ) && sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/ ) 1>/dev/null 2>&1 && echo "cloud-init removed" || echo "cloud-init not removed"

echo "Changer le domaine de la machine"
    ( sudo hostnamectl set-hostname "$HOSTNAME".tpadmin.local ) 1>/dev/null 2>&1 && echo "Hostname changed to $HOSTNAME.tpadmin.local" || echo "Hostname not changed"

( sudo apt update && sudo apt upgrade -y  && sudo apt install lynx -y ) 1>/dev/null 2>&1 && echo "lynx installed" || echo "lynx not installed"

```