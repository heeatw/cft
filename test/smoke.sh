#!/bin/bash
# Smoke test: exercises every cft command against a throwaway project, with an installed Chrome for Testing.
# Run from anywhere: test/smoke.sh. Uses the real ~/.chrome-for-testing browser (CFT_HOME to point elsewhere).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cft="$here/bin/cft"
tmp="$(cd "$(mktemp -d)" && pwd -P)"   # resolved: macOS /var → /private/var
trap 'CFT_PROJECT="$tmp/proj" "$cft" close >/dev/null 2>&1 || true; kill "${blocker:-}" 2>/dev/null || true; rm -rf "$tmp"' EXIT

pass=0
ok()   { pass=$((pass + 1)); echo "ok   $*"; }
fail() {
  echo "FAIL $*" >&2
  for f in "$tmp/open.err" "$tmp/proj/.chrome-for-testing/chrome.log" "$tmp/proj/.chrome-for-testing/headless.log"; do
    [ -s "$f" ] && { echo "--- $f" >&2; tail -40 "$f" >&2; }
  done
  exit 1
}

# A throwaway git project with a page in it.
mkdir -p "$tmp/proj"; git -C "$tmp/proj" init -q
cat > "$tmp/proj/index.html" <<'EOF'
<!doctype html><title>cft smoke</title><h1 id="h">static</h1>
<script>document.getElementById('h').textContent = 'rendered by script'</script>
EOF
export CFT_PROJECT="$tmp/proj"
url="file://$tmp/proj/index.html"

"$cft" help | grep -q '^cft' && ok "help" || fail "help"
"$cft" --version | grep -qE '^cft [0-9]+\.[0-9]+\.[0-9]+$' && ok "--version: $("$cft" --version)" || fail "--version"
"$cft" version | grep -q 'Google Chrome for Testing' && ok "version: $("$cft" version)" || fail "version"
[ -x "$("$cft" bin)" ] && ok "bin is executable" || fail "bin is executable"

profile=$("$cft" profile)
[ "$profile" = "$tmp/proj/.chrome-for-testing" ] || fail "profile: $profile"
[ -d "$profile/profile" ] && [ -d "$profile/headless" ] && [ -d "$profile/shots" ] && ok "profile dirs created" || fail "profile dirs created"
grep -q '^\.chrome-for-testing/$' "$tmp/proj/.git/info/exclude" && ok "profile excluded from git" || fail "profile excluded from git"
"$cft" profile >/dev/null; [ "$(grep -c '^\.chrome-for-testing/$' "$tmp/proj/.git/info/exclude")" = 1 ] && ok "exclude not duplicated" || fail "exclude not duplicated"

# A directory that isn't a git repo is its own project; once its profile exists, its subdirectories belong to it.
mkdir -p "$tmp/plain/sub/deeper"
[ "$(CFT_PROJECT="$tmp/plain/sub/deeper" "$cft" port)" != "$(CFT_PROJECT="$tmp/plain" "$cft" port)" ] && ok "non-git subdir is its own project before any profile exists" || fail "non-git subdir before profile"
rm -rf "$tmp/plain/sub/deeper/.chrome-for-testing"
[ "$(CFT_PROJECT="$tmp/plain" "$cft" profile)" = "$tmp/plain/.chrome-for-testing" ] && ok "non-git dir is its own project" || fail "non-git dir is its own project"
[ "$(CFT_PROJECT="$tmp/plain/sub/deeper" "$cft" profile)" = "$tmp/plain/.chrome-for-testing" ] && ok "non-git subdir resolves to the project above it" || fail "non-git subdir resolves to the project above it"
[ "$(CFT_PROJECT="$tmp/plain/sub/deeper" "$cft" port)" = "$(CFT_PROJECT="$tmp/plain" "$cft" port)" ] && ok "non-git subdir gets the project's port" || fail "non-git subdir gets the project's port"
[ ! -d "$tmp/plain/sub/.chrome-for-testing" ] && ok "no profile created in the subdir" || fail "no profile created in the subdir"
# $HOME is never a project: a profile there (where the shared browsers live) must not swallow every non-git directory.
mkdir -p "$tmp/plain/.chrome-for-testing/profile"
[ "$(HOME="$tmp/plain" CFT_PROJECT="$tmp/plain/sub" "$cft" profile)" = "$tmp/plain/sub/.chrome-for-testing" ] && ok "walk-up stops before \$HOME" || fail "walk-up stops before \$HOME"
rm -rf "$tmp/plain/sub/.chrome-for-testing"

port=$("$cft" port)
[ "$port" -ge 9300 ] && [ "$port" -le 9999 ] && ok "port $port in range" || fail "port $port in range"
[ "$("$cft" port)" = "$port" ] && ok "port is stable" || fail "port is stable"

# dom: the HTML after scripts ran.
"$cft" dom "$url" | grep -q 'rendered by script' && ok "dom shows script output" || fail "dom shows script output"

# shot: a non-empty PNG, default path and explicit path, with a size.
shot=$("$cft" shot "$url")
case "$shot" in "$profile/shots/"*.png) ;; *) fail "shot default path: $shot" ;; esac
[ -s "$shot" ] && [ "$(dd if="$shot" bs=1 skip=1 count=3 2>/dev/null)" = PNG ] && ok "shot default → $shot" || fail "shot default → $shot"
shot2=$("$cft" shot "$url" "$tmp/out.png" 800x600)
[ "$shot2" = "$tmp/out.png" ] && [ -s "$shot2" ] && ok "shot explicit path + size" || fail "shot explicit path + size"
if command -v python3 >/dev/null; then
  dims=$(python3 -c 'import struct,sys; d=open(sys.argv[1],"rb").read(24); print(*struct.unpack(">II", d[16:24]))' "$shot2")
  [ "$dims" = "800 600" ] && ok "shot is 800x600" || fail "shot dims: $dims"
fi
! "$cft" shot "http://127.0.0.1:1/nothing" "$tmp/none.png" >/dev/null 2>&1 && [ ! -s "$tmp/none.png" ] && ok "shot fails on an unreachable url" || fail "shot fails on an unreachable url"

# open / close, with the preferred port blocked: cft must pick the next free one.
python3 -c 'import socket,sys,time; s=socket.socket(); s.bind(("127.0.0.1",int(sys.argv[1]))); s.listen(1); time.sleep(600)' "$port" &
blocker=$!; disown "$blocker" 2>/dev/null || true
for _ in $(seq 1 50); do lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 && break; sleep 0.1; done
lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 || fail "blocker isn't listening on $port"
"$cft" close | grep -q 'not open' && ok "close when not open" || fail "close when not open"
out=$("$cft" open 2>"$tmp/open.err") || fail "open exited $?"
grep -q "port $port is taken" "$tmp/open.err" && ok "open reports the taken port" || fail "open reports the taken port"
used=$("$cft" port)
[ "$used" != "$port" ] && [ "$used" -gt 9299 ] && ok "open fell back to port $used" || fail "open fell back to port $used"
[[ "$out" == *"DevTools http://127.0.0.1:$used" ]] && ok "open prints the real DevTools url" || fail "open prints the real DevTools url"
curl -sf "http://127.0.0.1:$used/json/version" | grep -q '"Browser"' && ok "DevTools answers on $used" || fail "DevTools answers on $used"
[ -f "$profile/chrome.pid" ] && ok "pid file written" || fail "pid file written"
"$cft" open "$url" | grep -q "already open: http://127.0.0.1:$used" && ok "second open reuses the browser" || fail "second open reuses the browser"
for _ in $(seq 1 50); do curl -s "http://127.0.0.1:$used/json/list" | grep -q 'proj/index.html' && break; sleep 0.1; done
curl -s "http://127.0.0.1:$used/json/list" | grep -q 'proj/index.html' && ok "second open added the url as a tab" || fail "tab not listed"
pid=$(head -1 "$profile/chrome.pid")
"$cft" close | grep -q '^closed$' && ok "close" || fail "close"
sleep 0.5; ! kill -0 "$pid" 2>/dev/null && ok "browser process is gone" || fail "browser process is gone"
[ ! -f "$profile/chrome.pid" ] && ok "pid file removed" || fail "pid file removed"
kill "$blocker"; wait "$blocker" 2>/dev/null || true; blocker=
kill -0 "$blocker" 2>/dev/null && fail "blocker still alive"
[ "$("$cft" port)" = "$port" ] && ok "port back to preferred $port once free" || fail "port back to preferred $port once free"

# A stale pid file (process gone) is cleaned up, not trusted.
printf '%s\n%s\n' 999999 "$port" > "$profile/chrome.pid"
"$cft" close | grep -q 'not open' && [ ! -f "$profile/chrome.pid" ] && ok "stale pid file cleaned up" || fail "stale pid file cleaned up"

! "$cft" bogus >/dev/null 2>&1 && ok "unknown command fails" || fail "unknown command fails"

echo; echo "all $pass checks passed"
