#! /usr/bin/bash

ac=$1
wa=$2
tc=$3
loop=$4

i=0

g++ $ac -o ac.out
g++ $wa -o wa.out
g++ $tc -o tc.out

while true; do
    input="$(echo "$loop" | ./tc.out /dev/stdin)"

    ac_output=$( echo "$input" | ./ac.out /dev/stdin )
    timeout 1 echo "$input" | ./wa.out /dev/stdin > /dev/null

    if [ $? -eq 124 ]; then
	echo "TLE"
	echo "$input"
	break
    fi

    wa_output=$(echo "$input" | ./wa.out /dev/stdin )
    
    if [[ "$ac_output" != "$wa_output" ]]; then
	echo "Different"
	echo "$input"
	echo "$ac_output"
	echo "$wa_output"
	break
    fi
    
    (( i=i+1 ))
    echo "Test $i is success"
done

rm ac.out
rm wa.out
rm tc.out
