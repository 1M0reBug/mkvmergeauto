#!/bin/bash


mkdir "./utf-8"
for f in ./*.srt
do 
nfile=${f%.*t}
iconv -f ISO_8859-1 -t UTF-8 "$f" > "./utf-81/${nfile#./}_utf-8.srt" 
done