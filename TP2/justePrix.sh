#!/bin/bash
nombre=$(( $RANDOM % 1000 + 1 ))
findIt=0


while [ $findIt -ne 1 ]
do
    read -s 'Entre un nombre ' SAISI

    if [ $SAISI -gt $nombre ]; then
        echo "Plus petit"
    elif [ $SAISI -lt $nombre ]; then
        echo "Plus grand"
    else
        echo "Bravo !"
        findIt=1
    fi
done


