#!/bin/zsh
# Clean check: this kit must carry zero information about the maker's clients, students, staff or accounts,
# and no keys. This repo is PUBLIC: only the owner and the TAP OBM credit may be named. Runs before every push (pre-push hook) and in tests.
# The deny list lives OUTSIDE this repo (it names real people), default ~/team/ops/kit-denylist.txt,
# override with KIT_DENYLIST=/path. No deny list = the check fails; it never passes blind.
set -u
KIT="${0:A:h:h}"
LIST="${KIT_DENYLIST:-$HOME/team/ops/kit-denylist.txt}"
cd "$KIT" || exit 2
[ -s "$LIST" ] || { print "check-clean: deny list $LIST is missing or empty; refusing to pass."; exit 2; }

WORDS="$(mktemp)"; trap 'rm -f "$WORDS"' EXIT
grep -v -E '^\s*(#|$)' "$LIST" | sed 's/[[:space:]]*$//' | grep -v -i -x -E '(Annikka|TAP|TAP OBM|tapobm|tapobm\.com)' > "$WORDS"
# Also every AI employee id on the maker's own roster, if it is on this Mac.
[ -f "$HOME/team/roster.json" ] && /usr/bin/python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["agents"]))' "$HOME/team/roster.json" >> "$WORDS"

FILES=("${(@f)$(git ls-files --cached --others --exclude-standard)}")
# HyperFrames' own skills are copied unchanged from upstream; ordinary words like "tap" and the
# numbers in its code are not ours. They still get the key, email and file-type checks below.
OURS=("${(@)FILES:#skills/(hyperframes|hyperframes-cli|hyperframes-registry|media-use)/*}")
FAIL=0
report() { print -r -- "$1"; print -r -- "$2"; FAIL=1; }

# LICENSE is the one file allowed to name the kit's owner (the copyright holder).
hits=$(grep -n -I -i -w -F -f "$WORDS" -- "${OURS[@]}" 2>/dev/null | grep -v '^scripts/check-clean.sh:\|^LICENSE:')
[ -n "$hits" ] && report "Names from the deny list:" "$hits"

secrets=$(grep -n -I -E '(sk-ant-[A-Za-z0-9_-]{20}|sk-[A-Za-z0-9]{32}|gh[po]_[A-Za-z0-9]{30}|xox[bpa]-[0-9A-Za-z-]{20}|[0-9]{9,10}:AA[A-Za-z0-9_-]{30}|AIza[0-9A-Za-z_-]{35}|BEGIN [A-Z ]*PRIVATE KEY|eyJhbGciOi[A-Za-z0-9_-]{20})' -- "${FILES[@]}" 2>/dev/null | grep -v '^scripts/check-clean.sh:\|^engine/backup.sh:')
[ -n "$secrets" ] && report "Possible keys or tokens:" "$secrets"

ids=$(grep -n -I -E '(\+63|\b09[0-9]{2}[ -]?[0-9]{3}[ -]?[0-9]{4}\b|-100[0-9]{8,}|\b[0-9]{10,}\b)' -- "${OURS[@]}" 2>/dev/null | grep -v '^scripts/check-clean.sh:\|^engine/backup.sh:')
[ -n "$ids" ] && report "Phone numbers, chat ids or long account-style numbers:" "$ids"

emails=$(grep -n -I -o -E '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' -- "${FILES[@]}" 2>/dev/null | grep -v -E '@(example\.(com|org)|anthropic\.com)$')
[ -n "$emails" ] && report "Real-looking email addresses:" "$emails"

envs=$(print -l -- "${FILES[@]}" | grep -E '(\.env($|\.)|\.pem$|\.key$|credentials.*\.json$|browser-profiles/)')
[ -n "$envs" ] && report "Files that should never be in the kit:" "$envs"

if [ $FAIL -eq 0 ]; then
  print "check-clean: PASS (${#FILES[@]} files, $(wc -l < "$WORDS" | tr -d ' ') names checked)"
else
  print "check-clean: FAIL. Fix every line above before pushing."
fi
exit $FAIL
