# House-style fade for finished reels: fade in from black 0.5 s, fade out to black 1 s, sound too.
# Also writes <name>-cover.jpg (frame at 1 s) to use as the custom cover when you post, since frame 1 is now black.
# usage: fade.py OUT.mp4 [OUT2.mp4 ...]   (in place; a file already tagged house-fade is skipped, so it never fades twice)
import json, os, subprocess, sys

FIN, FOUT, TAG = 0.5, 1.0, 'house-fade'

def probe(f):
    r = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration:format_tags=comment', '-of', 'json', f],
                       capture_output=True, text=True, check=True)
    fmt = json.loads(r.stdout)['format']
    return float(fmt['duration']), fmt.get('tags', {}).get('comment', '')

for f in sys.argv[1:]:
    dur, comment = probe(f)
    if TAG in comment:
        print('skip (already faded)', f); continue
    tmp = f + '.fade.mp4'; st = round(dur - FOUT, 3)
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', f,
                    '-vf', f'fade=t=in:st=0:d={FIN},fade=t=out:st={st}:d={FOUT}',
                    '-af', f'afade=t=in:st=0:d=0.2,afade=t=out:st={st}:d={FOUT}',
                    '-c:v', 'libx264', '-crf', '19', '-preset', 'medium', '-pix_fmt', 'yuv420p',
                    '-c:a', 'aac', '-b:a', '192k', '-ac', '2', '-movflags', '+faststart',
                    '-metadata', f'comment={TAG}', tmp], check=True)
    os.replace(tmp, f)
    cover = os.path.splitext(f)[0] + '-cover.jpg'
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', '1.0', '-i', f, '-frames:v', '1', '-q:v', '2', cover], check=True)
    print('faded', f, '| cover', cover)
