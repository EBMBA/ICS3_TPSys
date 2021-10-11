#!/bin/bash
( ( sudo apt update && sudo apt upgrade -y ) 1>/dev/null 2>&1 && sudo apt install dnsutils bind9 bind9-doc -y ) 1>/dev/null 2>&1 && echo "Bind9 installed" || echo "Bind9 not installed" 

# Configuration de la zone tpadmin.local
echo "Configuration de la zone tpadmin.local"
( echo "zone \"tpadmin.local\" IN {
type master; 
file \"/etc/bind/db.tpadmin.local\"; 
};" | sudo tee -a /etc/bind/named.conf.local ) 1>/dev/null 2>&1 && echo "DNS configured for tpadmin.local" || echo "DNS configured for tpadmin.local"

sudo cp  /etc/bind/db.local /etc/bind/db.tpadmin.local
sudo sed -i -e 's/localhost/tpadmin.local/g'  /etc/bind/db.tpadmin.local
sudo sed -i -e 's/127.0.0.1/192.168.100.1/g'  /etc/bind/db.tpadmin.local

echo "zone \"100.168.192.in-addr.arpa\" {
type master;
file \"/etc/bind/db.192.168.100\";
};" | sudo tee -a /etc/bind/named.conf.local

mv db.127 db.192.168.100