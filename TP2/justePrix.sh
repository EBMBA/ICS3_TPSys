#!/bin/bash
nombre=$(( $RANDOM % 1000 + 1 ))
findIt=0


while [ $findIt -ne 1 ]
do
    read -s "Entre un nombre : " SAISI

    if [ $SAISI -gt $nombre ]; then
        echo "Plus petit"
    fi
    if [ $SAISI -lt $nombre ]; then
        echo "Plus grand"
    fi
    if [ $SAISI -eq $nombre ]; then
        echo "Bravo !"
        findIt=1
    fi
done


