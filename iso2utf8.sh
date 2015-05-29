#!/bin/bash

for f in ./*.srt
do
    exCharset=$(file "$f" | cut -d ':' -f 2 | cut -d ' ' -f 2)
    realCharset=$(iconv -l | grep -m 1 "$charset" | cut -d '/' -f 1)

    if ("$?" eq 0); then
        nfile=${f%.*t}
        iconv -f "$realCharset" -t UTF-8 "$f" > "./${nfile#./}.utf-8.srt"
    else
        echo "$realCharset : No such kind of charset !"
    fi
done