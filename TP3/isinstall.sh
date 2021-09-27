#!/bin/bash
while (("$#")) 
do
    (dpkg -l "$1" | grep "^ii") 1>/dev/null 2>&1 && echo "$1 installé" || echo "$1 non installé"
    shift
done

