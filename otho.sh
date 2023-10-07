#!/usr/bin/bash

Help()
{
    echo -e "Syntax:	otho.sh [ac file] [wa file] -i [input-file]"
    echo
    echo -e "-i [input-file]\t\tSpecify input file. Will override -t option"
    echo -e "-h\t\t\tPrint this help"
    echo -e "-o [output-file]\tSpecify file to which wa output must be saved"
    echo -e "-t [testcase-program]\tSpecify program which generates input"
    echo -e "-T <N>\t\t\tTLE time constraint in seconds. Default is 1 second"
    echo -e "-w <N>\t\t\tRun till N testcases give WA. Default is 1"
    echo -e "-p\t\t\tDisplay number of passed testcases"
}

compile()
{
    file=$1

    name=$( getfilename $file )
    ext=$( getextension $file )

    if [[ ! -f "$file" ]]; then
	echo "Input file $file does not exist."
	exit
    fi

    if [[ $ext  == "c" ]]; then
	o1=$( gcc $file -o $name.out 2>&1 | grep "error" )
    elif [[ $ext == "cpp" ]]; then
	o1=$( g++ $file -o $name.out 2>&1 | grep "error" )
    fi


    if [[ -n "$o1" ]]; then
	echo $o1
	echo
	exit
    fi

}

run()
{
    file=$1

    input=$2

    ext=$( getextension $file )

    if [[ $ext == "out" ]]; then
	echo -e "$( echo -e "$input" 2>&1 | ./$file /dev/stdin )"
    elif [[ $ext == "py" ]]; then
	echo $( python3 $file)
    fi
}

getfilename()
{
    echo "${1%.*}"
}

getextension()
{
    echo "${1##*.}"
}

inputflag=0
outputflag=0
outputfile=""
input=""
timeout=1
tc=""
wacases=1
wacasescounter=0
passed=0

ac=$1
wa=$2

shift 2

while getopts ":ht:i:T:o:w:p" option; do
    case $option in
	h)
	    Help
	    exit;;
	i)
	    inputfile=$OPTARG

	    if [[ ! -f "$inputfile" ]]; then
		echo "Input file $inputfile does not exist."
		exit
	    fi

	    input=$( cat $inputfile  )
	    inputflag=1;;
	t)
	    tc=$OPTARG;;
	T)
	    timeout=$OPTARG;;
	o)
	    outputfile=$OPTARG

	    if [[ ${outputfile::1} == "-" ]]; then
		echo "Error: Option '-o' expects a valid file name: $outputfile"
		exit
	    fi

	    if [[ -z "$outputfile" ]]; then
		echo "Didn't specify output file"
		exit
	    fi

	    outputflag=1;;
	w)
	    wacases=$OPTARG;;
	p)
	    passed=1;;
	\?)
	    echo "Invalid Option"
	    Help
	    exit;;
    esac
done

if [[ -z "$2"  ]]; then
    Help
    exit
fi

i=0

compile $ac
compile $wa
compile $tc

#o1=$( gcc $ac -o ac.out 2>&1 | grep "error" )
#o2=$( gcc $wa -o wa.out 2>&1 | grep "error" )

#if [ "$inputflag" -eq 0 ]; then
 #   o3=$( g++ $tc -o tc.out 2>&1 | grep "error" )
#fi

if [[ -n "$o1" || -n "$o2" || -n "$o3" ]]; then
    echo $o1
    echo $o2
    echo $o3
    echo
    Help
    exit
fi

while true; do
    if [ $inputflag -eq 0 ]; then
	input="$( run "$( getfilename $tc ).out" "1" )"
    fi

    ac_output="$( run "$( getfilename $ac ).out" "$input" )"

    if [ $outputflag -eq 1 ]; then
	timeout $timeout bash -c -- echo "$input" | $( getfilename $wa ).out /dev/stdin > "$outputfile"
    #else
	#timeout $timeout bash -c -- 'echo "$input" | ./wa.out /dev/stdin > /dev/null'
	#timeout $timeout echo "$input" | ./wa.out /dev/stdin > /dev/null
    fi

    if [ $? -eq 124 ]; then
	echo "TLE"
	echo "$input"
	break
    fi

    wa_output=$(run "$( getfilename $wa ).out" "$input" )

    if [[ -n $( diff -b <(echo "$ac_output") <(echo "$wa_output")) ]]; then
	echo
	echo "Failed"
	echo "$input"
	echo "----------------------------------"
	echo "$ac_output"
	echo "----------------------------------"
	echo "$wa_output"
	echo

	(( wacasescounter=wacasescounter+1 ))

	if [ "$outputflag" -eq 1 ]; then
	    echo "$input" > $outputfile
	    echo "----------------------------------" >> $outputfile
	    echo "$ac_output" >> $outputfile
	    echo "----------------------------------" >> $outputfile
	    echo "$wa_output" >> $outputfile
	fi

	if [ "$wacases" -eq "$wacasescounter" ]; then
	    break
	fi

    fi

    (( i=i+1 ))

    if [ "$passed" -eq 1 ]; then
	echo "Test $i Passed"
    fi

    if [ "$inputflag" -eq 1 ]; then
	break
    fi
done

rm $( getfilename $ac ).out
rm $( getfilename $wa ).out
rm $( getfilename $tc ).out &> /dev/null
