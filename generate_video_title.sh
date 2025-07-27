#!/bin/bash

set -e

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 <subtitle> <input> <output>"
	exit 1
fi

SUBTITLE=$1
INPUT=$2
OUTPUT=$3

WIDTH=1920
HEIGHT=1080
DURATION=5

# -f lavfi -i color=c=black:s=${WIDTH}x${HEIGHT}:r=60/1 \
# -f lavfi -i anullsrc=cl=mono:r=48000 \
ffmpeg -v quiet -stats \
-i ${INPUT} \
-vf "drawtext='\
fontfile=arialbd.ttf:
fontsize=96:
fontcolor=white:
y_align=baseline:
x=100:
y=$((HEIGHT - 100)):
text=${SUBTITLE}:
enable=between(t,0,${DURATION})
'" \
-c:v libx265 -preset ultrafast -x265-params "lossless=1:log-level=none" \
-c:a copy \
${OUTPUT}
