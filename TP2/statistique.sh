#!/bin/bash

function is_number()
{
	re='^[+-]?[0-9]+([.][0-9]+)?$'

	if ! [[ $1 =~ $re ]] ; then
		return 1
	else
		return 0
	fi
}

function is_inrange()
{
    if  [[ "$1" -ge -100  &&  "$1" -le 100 && "$2" -ge -100 && "$2" -le 100  &&  "$3" -ge -100  &&  "$3" -le 100 ]]
    then
        return 0
    else
        return 1
    fi
}

function get_max()
{
    if [[ "$1" -gt "$2"  &&  "$1" -gt "$2" ]]; then
        max="$1"
    fi
    if [[ "$3" -gt "$2"  &&  "$3" -gt "$1" ]]; then
        max="$3"
    fi
    if [[ "$2" -gt "$1"  &&  "$2" -gt "$3" ]]; then
        max="$2"
    fi

    echo "max : $max"
}

function get_min()
{
    if [[ "$1" -lt "$2"  &&  "$1" -lt "$2" ]]; then
        min="$1"
    fi
    if [[ "$3" -lt "$2"  &&  "$3" -lt "$1" ]]; then
        min="$3"
    fi
    if [[ "$2" -lt "$1"  &&  "$2" -lt "$3" ]]; then
        min="$2"
    fi
    echo "min : $min"
}

function get_average()
{
    somme=0
    nbrElement=0
    while (("$#")) 
    do
        somme=$(("$somme"+"$1"))
        nbrElement=$(("$nbrElement"+1))
        shift
    done
    moyenne=$(("$somme"/"$nbrElement"))
    echo "moyenne : $moyenne"
}

is_number "$@"
nbr1=$?


is_inrange "$@"
goodRange=$?

if [[ $nbr1 -eq 0  && $goodRange -eq 0 ]]
then
    get_average "$@"
    get_max "$@"
    get_min "$@"
fi