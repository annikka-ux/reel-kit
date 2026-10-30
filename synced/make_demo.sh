#!/bin/zsh
# make_demo.sh : builds a test "talking head" (a colour background + the Mac's built-in voice) so you can try
# the whole pipeline before using real footage. Writes demo.mp4 here. macOS only (uses `say`).
set -e
cd ${0:A:h}
TXT="Your team is not failing because of talent. They are failing because of order. Same people, same tools, but three things changed. Answer first. Pause, do not fill. End down, not up. Your client is listening for one thing: can I stop worrying?"
say -v Samantha -r 165 -o demo.aiff "$TXT"
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 demo.aiff)
ffmpeg -loglevel error -y -f lavfi -i "gradients=s=1080x1920:c0=0x3a4a48:c1=0x1d2726:speed=0.01:d=${D}" -i demo.aiff \
  -shortest -c:v libx264 -pix_fmt yuv420p -r 30 -c:a aac -b:a 160k demo.mp4
rm -f demo.aiff
print "demo.mp4 ($D s). Next: ./transcribe.sh demo.mp4"
