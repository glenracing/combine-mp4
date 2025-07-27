#!/bin/bash

set -e

# Parse command line arguments
if [[ $# -lt 3 ]]; then
	echo "Usage: $0 <titles file> <output> [inputs...]"
	echo
	echo "<titles file> is a text file where the first and second lines contain"
	echo "the main title and subtitle, respectively, and subsequent lines"
	echo "contain the titles for each video in the order they will be passed to"
	echo "this script."
	echo
	echo "If the main title and subtitle are both blank, the main title will not"
	echo "be generated. If any of the other lines are blank, a title will not be"
	echo "generated for the corresponding video."
	echo
	exit 1
fi

TITLES_PATH=$1
OUTPUT=$2
INPUTS=()
for (( i=3; i < $#+1; i++ ))
do
	INPUTS+=(${!i})
done
num_inputs=${#ffmpeg_inputs[@]}

# Parse titles file
if [[ $(cat "${TITLES_PATH}" | wc -l) -lt 2 ]]; then
	echo "Error: ${TITLES_PATH} must contain at least the main title and subtitle lines."
	exit 1
fi

SAVEIFS=$IFS
IFS=$'\n'
TITLES=$(cat "${TITLES_PATH}")
IFS=$SAVEIFS

# Print arguments
echo "Title: ${TITLES[0]}"
echo "Subtitle: ${TITLES[1]}"
echo "Number of videos: ${#INPUTS[@]}"
echo

ffmpeg_inputs=()
num_steps=$((${num_inputs} + 2))

# Generate main title
main_title_path=$(dirname "${INPUTS[0]}")/title.mp4
echo -n "(1/${num_steps}) "
if [[ ! -f ${main_title_path} ]]; then
	echo "Generating main title..."
	$(dirname "$0")/generate_main_title.sh "${TITLES[0]}" "${TITLES[1]}" "${main_title_path}"
else
	echo "Main title already generated"
fi
ffmpeg_inputs+=("-i ${main_title_path}")

# Generate video titles
for (( i=0; i < $num_inputs; i++ ))
	input_filename=$(basename "${INPUTS[i]}")
	echo -n "(${i}/${num_steps}) ${input_filename} "
	if [[ -n "${TITLES[i]}" ]]; then
		video_title_path=$(dirname "${INPUTS[i]}")/title_$(basename "${INPUTS[i]}")
		if [[ ! -f "${video_title_path}" ]]; then
			echo "Generating video title..."
			$(dirname "$0")/generate_video_title.sh "${TITLES[i]}" "${INPUTS[i]}" "${video_title_path}"
		else
			echo "Video title already generated"
		fi
		ffmpeg_inputs+=("-i ${video_title_path}")
	else
		echo
		ffmpeg_inputs+=("-i ${INPUTS[i]}")
	fi
done

# Create ffmpeg stream order string
ffmpeg_streams=""
for (( i=0; i < $num_inputs; i++ ))
do
	ffmpeg_streams+="[${i}:v:0][${i}:a:0]"
done

# Combine the videos
output_filename=$(basename "${OUTPUT}")
echo "(${num_steps}/${num_steps}) Combining videos into ${output_filename}..."
ffmpeg -v quiet -stats \
${ffmpeg_inputs[*]} \
-filter_complex "${ffmpeg_streams}concat=n=${num_inputs}:v=1:a=1[outv][outa]" \
-map "[outv]" \
-map "[outa]" \
-c:v libx265 -crf 18 -preset ultrafast -x265-params "log-level=none" \
-c:a aac \
${OUTPUT}
