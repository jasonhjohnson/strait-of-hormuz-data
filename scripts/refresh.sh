#!/usr/bin/env bash
# Mirror the public straits.live datasets into ./data.
#
# Run daily by the GitHub Action (.github/workflows/refresh.yml) and usable
# locally. Pulls only from public, no-key endpoints, so it needs no secrets
# and has no dependency on the upstream data-collection host.
#
# Resilient by design: a single blocked or flaky endpoint logs a warning and
# keeps the previous file rather than aborting the whole refresh. The run only
# fails if nearly everything fails, which signals a real outage.
set -uo pipefail

BASE="${STRAITS_BASE:-https://straits.live}"
# A real, identifying user-agent. The default curl UA gets a 403 from the edge
# on the non-cached routes (e.g. /status); an honest UA passes and is also the
# polite thing to send.
UA="strait-of-hormuz-data mirror (+https://github.com/jasonhjohnson/strait-of-hormuz-data)"

cd "$(dirname "$0")/.."
mkdir -p data

fail=0
total=0

# fetch <url> <dest> [json]
# Downloads to a temp file and only replaces <dest> on success, so a failed
# pull never truncates a good prior copy. Pass "json" to pretty-print + sort
# keys for stable diffs.
fetch() {
  local url="$1" dest="$2" mode="${3:-raw}" tmp
  total=$((total + 1))
  tmp="$(mktemp)"
  if curl -fsSL --retry 3 --retry-delay 5 -A "$UA" "$url" -o "$tmp"; then
    if [ "$mode" = json ] && command -v python3 >/dev/null 2>&1; then
      python3 -m json.tool --sort-keys "$tmp" >"$dest" 2>/dev/null || cp "$tmp" "$dest"
    else
      cp "$tmp" "$dest"
    fi
    echo "ok    $dest"
  else
    echo "WARN  $dest (fetch failed, keeping previous copy)"
    fail=$((fail + 1))
  fi
  rm -f "$tmp"
}

fetch "$BASE/data/transits.csv"                       data/transits.csv
fetch "$BASE/data/hormuz-index.csv"                   data/hormuz-index.csv
fetch "$BASE/data/hormuz-index.csv?granularity=daily" data/hormuz-index-daily.csv
fetch "$BASE/data/oil.csv"                            data/oil.csv
fetch "$BASE/data/events.csv"                         data/events.csv
fetch "$BASE/data/status.csv"                         data/status.csv
fetch "$BASE/status"                                  data/status.json            json
fetch "$BASE/api/index"                               data/hormuz-index.json      json
fetch "$BASE/api/v1/transits?history=1&limit=365"     data/transits.json          json

echo "done: $((total - fail))/$total fetched"

# Only fail the job on a broad outage, not a single blocked endpoint.
if [ "$fail" -ge "$total" ]; then
  echo "all fetches failed; failing run"
  exit 1
fi
exit 0
