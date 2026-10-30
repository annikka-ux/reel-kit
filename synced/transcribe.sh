#!/bin/zsh
# transcribe.sh VIDEO [OUT.json] : word-level timings with whisper.cpp (free, local).
# One word per segment (-ml 1 -sow) with DTW timestamps, so every graphic can land on its word.
# Model: set WHISPER_MODEL, default ~/whisper-models/ggml-medium.bin (setup.sh downloads it).
set -e
IN=$1; OUT=${2:-${IN:r}-words.json}
MODEL=${WHISPER_MODEL:-$HOME/whisper-models/ggml-medium.bin}
[ -f "$MODEL" ] || { print "No whisper model at $MODEL. Run ../setup.sh or set WHISPER_MODEL."; exit 1; }
DTW=$(basename "$MODEL" .bin | sed 's/^ggml-//; s/\.en$/.en/')
WAV=$(mktemp -t words).wav
ffmpeg -loglevel error -y -i "$IN" -ar 16000 -ac 1 "$WAV"
whisper-cli -m "$MODEL" -l ${WHISPER_LANG:-en} -ml 1 -sow -dtw "$DTW" -oj -of "${OUT%.json}" -f "$WAV" >/dev/null 2>&1
rm -f "$WAV"
print "words -> $OUT"
