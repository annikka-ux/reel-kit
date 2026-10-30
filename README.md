# Show What You Say: word-synced reels with Claude Code

*Built by Annikka at [TAP OBM](https://tapobm.com). Free to use under the MIT license.*

Turn a talking-head video into a vertical reel where **every graphic shows exactly what you're saying that second**: karaoke captions, the Signature look (cream, teal, gold, kinetic type, shape morphs, rings, sparkles, a 3D logo card) and a CTA end card. It runs locally on your Mac with free tools; you need Claude Code, which comes with a paid Claude plan (Pro or higher).

- **Under the hood** it uses a free, open-source HTML-to-video renderer (credited in `THIRD_PARTY_NOTICES.md`). Its Claude Code skills are included in `skills/`, and the renderer downloads automatically the first time you render.

## What's inside

| Folder | What it is |
|---|---|
| `signature-look/` | The 10-second Signature look sample (`index.html`) and its render (`signature-look-preview.mp4`). Use it as a reference for title cards and b-roll. |
| `synced/` | The word-synced pipeline: `transcribe.sh` → `gen.py` + a beats file → `finish.sh`. Includes a demo you can run in 2 minutes. |
| `synced/brands.json` | Your colors, fonts, logo and end-card CTA. Two example skins: `classic` (cream/teal/gold) and `bright` (teal/yellow). |
| `skills/reel/` | The `/reel` Claude Code skill: the whole standard, from script to cut, graphics, QA and hand-off. |
| `skills/hyperframes*`, `skills/media-use/` | The renderer's own Claude Code skills (Apache-2.0, unchanged). |

## Setup (once)

```bash
git clone https://github.com/annikka-ux/show-what-you-say.git ~/show-what-you-say
```

```bash
~/show-what-you-say/setup.sh
```

This installs Node, ffmpeg and whisper.cpp with Homebrew if they're missing, downloads the free whisper medium model (1.5 GB), and copies the skills into `~/.claude/skills`. Restart Claude Code afterwards.

Optional: turn off the renderer's anonymous usage stats with `npx hyperframes telemetry --help`. Don't sign in to HeyGen or set a `HEYGEN_API_KEY` unless you want its paid features. Nothing in this kit needs them.

## Try the demo

```bash
cd ~/show-what-you-say/synced && ./make_demo.sh && ./transcribe.sh demo.mp4 && python3 gen.py demo.mp4 demo-words.json beats_example classic && ./finish.sh hf-classic demo.mp4 demo-classic.mp4
```

`demo-classic.mp4` is a 20-second reel built on a test voice. Swap `classic` for `bright` to see the second skin.

## Make a real reel

The easy way: open Claude Code and type `/reel ~/Downloads/my-video.mov`. It writes the script and cut list first, waits for your OK, then builds, checks and hands back the MP4.

By hand:

1. **Cut it tight.** Keep only your best 45-60 seconds, no retakes. The video should be 1080x1920 (vertical).
2. **Transcribe:** `./transcribe.sh cut.mp4` writes `cut-words.json` with a start time for every word.
3. **Write the beats:** copy `beats_example.py` to `beats_myvideo.py`. Each beat enters on the word it illustrates (`g.at('order')` looks up the time) and leaves when you move on. Ready-made beats: `card`, `old_vs_new`, `tag`, `side_chips`, `checklist`, `point`, `cutaway_message`, `big_number`, `chat`.
4. **Generate:** `python3 gen.py cut.mp4 cut-words.json beats_myvideo classic`
5. **Check:** `cd hf-classic && npx --yes hyperframes@0.8.210 check && npx --yes hyperframes@0.8.210 snapshot --at 2,5,9`
6. **Finish:** `./finish.sh hf-classic cut.mp4 final.mp4 music.mp3` renders the video and adds your voice at -14 LUFS, a 6% music bed and a fade in/out, plus `final-cover.jpg`.

Music isn't included (license). Free beds: https://mixkit.co/free-stock-music/ (pick confident, driving tracks).

## Make it your brand

Edit `synced/brands.json`: `primary`, `accent`, `bg`, `ink`, and swap your logo into `synced/img/`. For the Signature look sample, change the five colors at the top of `signature-look/index.html` and replace `assets/img/logo.png`.

## The rules that make it look good

- A graphic shows **exactly** what you're saying that second. Nothing decorative.
- Something changes every 2-3 seconds.
- Hook line on screen at frame 0, then repeated near the end.
- Never cover the face. Cards go in the lower-middle area, chips at the sides, captions just below.
- Every version ends with a CTA card. The clickable link goes in the first comment, not the caption.

## Credits

Built by Annikka at [TAP OBM](https://tapobm.com), where we build AI employees that run operations inside service businesses. If this kit saves you an afternoon, that's the idea. Questions or wins: share them in the Discussions tab.

License: MIT (see `LICENSE`). The renderer (HyperFrames), the fonts and whisper.cpp keep their own licenses (see `THIRD_PARTY_NOTICES.md`).
