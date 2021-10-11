( ( ( echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg ) && sudo apt-get purge cloud-init -y ) && sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/ ) 1>/dev/null 2>&1 && echo "cloud-init removed" || echo "cloud-init not removed"

echo "Changer le domaine de la machine"
    ( sudo hostnamectl set-hostname "$HOSTNAME".tpadmin.local ) 1>/dev/null 2>&1 && echo "Hostname changed to $HOSTNAME.tpadmin.local" || echo "Hostname not changed"

( sudo apt update && sudo apt upgrade -y  && sudo apt install lynx -y ) 1>/dev/null 2>&1 && echo "lynx installed" || echo "lynx not installed"

echo " Changement de la configuration reseau"
VARINTERFACE1=$(ip a | grep -w 2 | cut -d: -f2)
VARNETCONF=$(ls /etc/netplan/)
( echo "
network:
    ethernets:
        $VARINTERFACE1:
            dhcp4: true          
    version: 2
" | sudo tee /etc/netplan/"$VARNETCONF" && sudo netplan apply && sudo systemctl restart systemd-networkd ) 1>/dev/null 2>&1 && echo "Network configuration good" || echo "Error in the network configuration"
