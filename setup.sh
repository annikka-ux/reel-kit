#!/bin/zsh
# setup.sh : one-time setup on a Mac. Installs the free tools, the whisper model and the Claude Code skills.
# Safe to run again. Nothing here signs in anywhere or costs money.
set -e
KIT=${0:A:h}
need() { command -v $1 >/dev/null 2>&1; }
need brew || { print "Install Homebrew first: https://brew.sh"; exit 1; }
need node || brew install node
need ffmpeg || brew install ffmpeg
need whisper-cli || brew install whisper-cpp
need python3 || brew install python

M=$HOME/whisper-models/ggml-medium.bin
if [ ! -f $M ]; then
  mkdir -p ${M:h}
  print "Downloading the whisper medium model (about 1.5 GB, one time)..."
  curl -L --fail -o $M https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin
fi

mkdir -p $HOME/.claude/skills
for s in $KIT/skills/*(/); do
  n=${s:t}
  if [ -e $HOME/.claude/skills/$n ]; then print "skill $n already installed, leaving it as is"; else cp -R $s $HOME/.claude/skills/; print "installed skill $n"; fi
done

npx --yes hyperframes@0.8.210 --version >/dev/null && print "HyperFrames OK"
print "Setup done. Restart Claude Code so it loads the skills, then try: cd $KIT/synced && ./make_demo.sh"
