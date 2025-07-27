#!/bin/sh

set -e

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 <title> <subtitle> <output>"
	exit 1
fi

TITLE=$1
SUBTITLE=$2
OUTPUT=$3

WIDTH=1920
HEIGHT=1080
DURATION=5

ffmpeg -v quiet -stats \
-f lavfi -i color=c=black:s=${WIDTH}x${HEIGHT}:r=60/1 \
-f lavfi -i anullsrc=cl=mono:r=48000 \
-vf "drawtext='\
fontfile=arialbd.ttf:
fontsize=128:
fontcolor=white:
y=$(($HEIGHT / 2 - 100)):
boxw=${WIDTH}:
text_align=T+C:
text=${TITLE}
',
drawtext='\
fontfile=arial.ttf:
fontsize=96:
fontcolor=white:
y=$(($HEIGHT / 2 + 100)):
boxw=${WIDTH}:
text_align=T+C:
text=${SUBTITLE}
'" \
-c:v libx265 -preset ultrafast -x265-params "lossless=1:log-level=none" \
-c:a pcm_s16be \
-t ${DURATION} \
${OUTPUT}
