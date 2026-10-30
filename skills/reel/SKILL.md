---
name: reel
description: Show What You Say reel, start to finish. Use when the user types /reel, or asks to make, cut or edit a reel or short from a video, class, call or file. Turns talking-head footage into a vertical reel where every graphic shows exactly what is being said, with karaoke captions and a CTA end card. Script and cut list first, then build, QA and hand over.
argument-hint: "[video file] [brand key from brands.json] [what the CTA pushes]"
---

# /reel: the Show What You Say standard

Input: `$ARGUMENTS`. Expected: the video, the brand (a key in `synced/brands.json`, or "all" for one version per brand) and the goal (what the end card pushes). Fill in anything missing from the standard below; ask only if the video itself is missing. Load the `hyperframes` skill before building. The kit lives where the user cloned it (default `~/show-what-you-say`).

## How the user asks
- `/reel [video]` runs this whole file.
- Optional add-ons: "brand: bright", "CTA: free class", "under 45 seconds", "hook is the line about X", "no stops" (skip the step 2 pause).
- `/reel script [topic]`: write a ~45 s script to record, not an edit. One picturable idea per sentence, hook in sentence one, the user's real facts only, ending with a spoken CTA line. Paste it inline and stop.
- When you hand back a finished reel, remind them once of the recording habit: say the main point in the first sentence, end with the CTA line.

## 1. Find the footage and the best lines
- `synced/transcribe.sh VIDEO` gives word times (whisper.cpp, local, free).
- Make a contact sheet, one frame every 10 s. Note where the speaker's face is and every moment someone else is on screen or heard.
- Choose 45-60 s of the speaker's own words (75 s max, 90 s hard cap): a hook line for the cold open, the story, the payoff. Cut retakes and rambles. No income claims, no faces of clients or students.
- Check every date and price against the live page. Prices change: prefer no prices on video.

## 2. Script + cut list FIRST (stop here)
- Write `SCRIPT.md`: a table of time | words (with source time) | graphic, the end card facts, what was left out and why, and any quality warning.
- Paste it inline. Ask "Build it?" and wait for a yes.

## 3. Build (after the yes)
- Cut on silences (`ffmpeg silencedetect`, about -33 dB), never mid-word. Alternate small punch-ins to hide jump cuts. Re-transcribe the finished cut.
- Copy `synced/beats_example.py` to `beats_<name>.py` and write `build(g)` from the new word times. Use `g.at('word', after)` instead of hard-coded seconds. Ready-made beats in `gen.py`: `card`, `old_vs_new`, `tag`, `side_chips`, `checklist`, `point`, `cutaway_message`, `big_number`, `chat`, plus `clip`/`T`/`pop`/`out` for custom ones.
- The rule that makes it work: every graphic shows exactly the words being said that second, enters on that word, leaves when the speaker moves on, and something changes every 2-3 s. No decorative graphics. Never cover the face: cards in the lower-middle band, chips at the sides, captions at y≈1252 inside the 168-1330 px safe band.
- Cold open: the hook line is on screen at frame 0 and comes back near the end as a callback.
- `python3 gen.py CUT.mp4 CUT-words.json beats_<name> BRAND` writes `hf-BRAND/`. The CTA end card comes from `brands.json` (eyebrow, title, detail, URL, "Link in the first comment"). Put the clickable link in the post's first comment, not the caption.
- Graphic look (the Signature look): cream / deep teal / gold by default, caps eyebrows, heavy sans for the "old" word with a strike, italic serif accent for the payoff word, shape morphs, rotating rings, 4-point sparkles, a 3D card with the logo. `signature-look/index.html` is the 10 s reference; reuse its moves for title cards and b-roll.
- `./finish.sh hf-BRAND CUT.mp4 OUT.mp4 [music.mp3]`: render, voice at -14 LUFS, music bed at 6%, house fade and a cover image. Pick confident, driving music beds, not spa music (Mixkit's free library works; check its license).

## 4. QA, then hand over
- `npx hyperframes check` inside `hf-BRAND`. Fix every error; contrast warnings mid-transition are fine.
- `npx hyperframes snapshot --at <every beat>` and read the frames before rendering.
- After rendering, a 1 fps contact sheet of the final MP4: only the speaker on screen, nothing over the face, all text readable, captions match the audio.
- Hand over the MP4 and cover, with a caption draft and the first-comment link.
