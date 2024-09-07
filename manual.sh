#!/usr/bin/env bash

# Generate timestamp formatted as YYYY-MM-DD_HH-mm
timestamp=$(date +"%Y-%m-%d_%H-%M")

# Define the output filename with the timestamp
output_file="output_${timestamp}.mp4"

# ffmpeg -i multiple_water_mark.mp4 -filter:v "delogo=x=20:y=40:w=400:h=50" "$output_file"

# ffmpeg -i multiple_water_mark.mp4 -filter:v "delogo=x=20:y=40:w=400:h=50:show=0:enable='between(t,0,end)'" "$output_file"

# ffmpeg -i multiple_water_mark.mp4 -filter:v "delogo=x=30:y=30:w=400:h=50:show=1" "$output_file"

# leftTop "delogo=x=20:y=40:w=360:h=50:enable='between(t,0,10)'"
# rightTop "delogo=x=20:y=40:w=360:h=50:enable='between(t,10,20)'"
# rightBottom "delogo=x=1423:y=972:w=360:h=50"
leftBottom="delogo=x=30:y=995:w=335:h=55"

# ffmpeg -hide_banner -stats -i ./test/multiple_water_mark.mp4 -vf $leftBottom ./test/$output_file
# ffmpeg -i ./test/multiple_water_mark.mp4 -c:v libx264 -crf 23 -preset fast -profile:v high -bf 2 -me_method umh -g 250 -pix_fmt yuv420p -c:a aac -b:a 128k ./test/$output_file

# COMMAND BREAKDOWN
# -c:v libx264: Uses the H.264 codec for video compression.
# -crf 23: Sets the Constant Rate Factor to 23, balancing quality and file size. Adjust between 18-28 if needed (lower values mean higher quality but larger files).
# -preset medium: Balances encoding speed and compression efficiency.
# -profile:v main: Uses the “main” profile for good compression and wide device compatibility.
# -level 4.0: Sets the H.264 level to 4.0 for broad compatibility while allowing for higher quality/bitrates than 3.1.
# -movflags +faststart: Moves metadata to the start of the file for faster video startup when streaming.
# -maxrate 4M -bufsize 8M: Limits the maximum bitrate to 4 Mbps with an 8 Mbps buffer. Adjust these values based on your video’s original quality and target streaming bitrate.
# -c:a aac -b:a 128k: Uses the AAC codec for audio with a 128k bitrate.

#  MP4 CODEC SOFTWARE ENCODING
# ffmpeg -i ./test/multiple_water_mark.mp4 \
#     -vf "$leftBottom" \
#     -c:v libx264 \
#     -crf 23 \
#     -preset medium \
#     -profile:v main \
#     -level 4.0 \
#     -movflags +faststart \
#     -maxrate 4M \
#     -bufsize 8M \
#     -c:a aac \
#     -b:a 128k \
#     ./test/$output_file

# APPLE CODEC HARDWARE ENCODING
ffmpeg -i ./test/multiple_water_mark.mp4 \
    -vf "$leftBottom" \
    -c:v hevc_videotoolbox \
    -allow_sw 1 \
    -q:v 70 \
    -tag:v hvc1 \
    -profile:v main \
    -r 30 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    -c:a aac \
    -b:a 128k \
    ./test/$output_file

# Debuging with ffplay
# ffplay -i ./test/multiple_water_mark.mp4 -vf "delogo=x=100:y=50:w=200:h=100:show=1"
# ffplay -i input.mp4 -vf “drawbox=x=100:y=50:w=200:h=100:color=red@0.5”