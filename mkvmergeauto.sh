#!/bin/bash

function show_help {

	help=$(cat<<EOF
USAGE:
	./mkvmergeauto.sh -i <inputDir> -S <seasonNumber> -o <outDir> -s <subtitlesDir> -n <seriesName> -N <number> [-f <from>]

OPTIONS:
	
	-i | --input     : <inputDir> is the folder where all video files are stored it's "./"
	-o | --output    : <outDir> pecise the output dir of final MKV files otherwise it's ./MKV
	-s | --subtitles : <subtitlesDir> precise the folder where are stored the subtitles SRT files
					   by default it's ./subtitles
	-S | --season    : <seasonNumber> precise the season number of the series
	-n | --name      : <seriesName> A pattern conaining %S and %E like 'Breaking.Bad.S%SE%E.avi'
					   it precise the pattern of the file to search. By default it's all the .avi files
	-f | --from      : the starting episode number to encode, name is obligatory if used
	-N | --number    : number of episodes to encode
	-h | --help      : print this message and quit 
EOF
);

echo "$help";

exit 0;
}

ARGS=$(getopt -o i:S:o:s:n:N:f:h --long input:,season:,out:,subtitles:,name:,number:,from:,help \
      -n 'mkvmergeauto.sh' -- "$@")

if [ $? != 0 ] ; then 
	show_help
fi

eval set -- "$ARGS";

#CONSTANTS
DEFAULT_INPUT="."
DEFAULT_OUTPUT="MKV"
DEFAULT_SUBTITLES="subtitles"
DEFAULT_NAME="*.avi"
#/CONSTANTS
#VARIABLES
season=1
number=0
from=0
name="$DEFAULT_NAME"
input="$DEFAULT_INPUT"
output="$DEFAULT_OUTPUT"
subtitles="$DEFAULT_SUBTITLES"
#/VARIABLES

while true; do
  case "$1" in
    -h|--help)
      shift;
      show_help
      ;;
    -S|--season)
		season="$2";
		shift 2
		;;
	-N|--number)
		number="$2"
		shift 2
		;;
	-n|--name)
		name="$2"
		shift 2
		;;
	-o|--output)
		output="$2"
		shift 2
		;;
	-i|--input)
		input="$2"
		shift 2
		;;
	-s|--subtitles)
		subtitles="$2"
		shift 2
		;;
	-f|--from)
		from="$2"
		shift 2
		;;
    --)
      shift
      break
      ;;
    *)
      echo "erreur interne"
      exiting 1 ;;
  esac
done

#VERIFICATION
if [[ -z "$season" || "$season" -le 0 ]];then
	echo "Type a Season number > 0"
	show_help
fi

if [[ -z "$name" ]];then
	show_help
fi

if [[ -z "$input" || ! -d "$input" ]];then
	echo "Input dir is not valid"
	show_help
fi

if [[ -z "$output" ]];then
	mkdir -p "$DEFAULT_INPUT/$DEFAULT_OUTPUT";
	output="$DEFAULT_INPUT/$DEFAULT_OUTPUT"
fi

if [[ ! -d "$output" ]];then
	mkdir -p "$output"
fi

if [[ -z "$subtitles" || ! -d "$subtitles" ]];then
	echo "Subtitles dir is not valid"
	show_help
fi

if [[ -z "$from" || "$from" -lt 0 ]];then
	echo "From value is not valid"
	show_help
fi

if [[ -z "$number" || "$number" -lt 0 ]];then
	echo "Number value is not valid"
	show_help
fi

if [[ "$name" = "$DEFAULT_NAME" && "$from" -ne 0 ]];then
	echo "Precise a name pattern !"
	show_help
fi
#/VERIFICATION

#Just adding a zero to be more aesthetic
if [[ "$season" -lt 10 ]];then
	season="0$season"
fi

#We want the list of files which are of the same pattern as defined with name
list=""
if [[ "$name" = "$DEFAULT_NAME" ]];then
	if [[ "$number" -eq 0 ]];then
		list=$(find "$input" -maxdepth 1 -path "$name")
	else
		list=$(find "$input" -maxdepth 1 -path "$name" | head "-$number")
	fi
else
	if [[ "$number" -eq 0 ]];then
		ok=true
		index="$from"
		while [[ "$ok" = true ]];do
			if [[ "$index" -lt 10 ]];then
				index="0$index"
			fi
			episode=$(echo "$name" | sed -e "s/\%S/$season/" -e "s/\%E/$index/")
			if [[ -f "$input/$episode" ]];then
				(( index ++ ))
				list="$list $episode"
			else
				ok=false
			fi
		done
	else
	#In this case we now how many episodes we have to merge
		ok=true
		index="$from"
		while [[ "$ok" = true ]];do
			episode=$(echo "$name" | sed -e "s/\%S/$season/" -e "s/\%E/$index/")
			difference=$(( index - from - number ))
			#A verification in plus has to be done ! becaus of $number
			if [[  "$difference" -le 0 ]];then
				ok=false
			elif [[ -f "$input/$episode" ]];then
				(( index ++ ))
				list="$list $episode"
			else
				ok=false
			fi
		done
	fi
fi

for f in $list;do
	outputEpisode="${f%.*}.mkv"
	subtitleEpisode="${f%.*}.srt"
	 #Seems to be working have to test in real cases
	echo "mkvmerge -v -o \"$output/$outputEpisode\"  \"--language\" \"0:eng\" \"--forced-track\" \"0:no\" \"--language\" \"1:eng\" \"--forced-track\" \"1:no\" \"-a\" \"1\" \"-d\" \"0\" \"-S\" \"-T\" \"--no-global-tags\" \"--no-chapters\" \"(\" \"$input/$f\" \")\" \"--forced-track\" \"0:no\" \"-s\" \"0\" \"-D\" \"-A\" \"-T\" \"--no-global-tags\" \"--no-chapters\" \"(\" \"$subtitles/$subtitleEpisode\" \")\" \"--track-order\" \"0:0,0:1,1:0\""
	mkvmerge -v -o "$output/$outputEpisode"  "--language" "0:eng" "--forced-track" "0:no" "--language" "1:eng" "--forced-track" "1:no" "-a" "1" "-d" "0" "-S" "-T" "--no-global-tags" "--no-chapters" "(" "$input/$f" ")" "--forced-track" "0:no" "-s" "0" "-D" "-A" "-T" "--no-global-tags" "--no-chapters" "(" "$subtitles/$subtitleEpisode" ")" "--track-order" "0:0,0:1,1:0"
done

echo "Bye !"
exit 0