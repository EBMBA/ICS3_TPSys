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
    while (("$#")) 
    do
        if [[ "$1" -le -100  ||  "$1" -ge 100 ]] 
        then
            return 1
        fi
        shift
    done
    return 0
}

function get_max()
{
    max="$1"
    while (("$#")) 
    do
        if [[ "$1" -gt "$max" ]] 
        then
            max="$1"
        fi
        shift
    done
    

    echo "max : $max"
}

function get_min()
{
    min="$1"
    while (("$#")) 
    do
        if [[ "$1" -lt "$min" ]] 
        then
            min="$1"
        fi
        shift
    done
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