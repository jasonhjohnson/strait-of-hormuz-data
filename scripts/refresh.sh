#!/usr/bin/env bash
# Mirror the public straits.live datasets into ./data.
#
# Run daily by the GitHub Action (.github/workflows/refresh.yml) and usable
# locally. Pulls only from public, no-key endpoints, so it needs no secrets
# and has no dependency on the upstream data-collection host.
set -euo pipefail

BASE="${STRAITS_BASE:-https://straits.live}"
cd "$(dirname "$0")/.."
mkdir -p data

fetch() {
  curl -fsSL --retry 3 --retry-delay 5 "$1" -o "$2"
  echo "ok  $2"
}

# Pretty-print + sort keys so JSON diffs stay readable and stable.
fetch_json() {
  local tmp
  tmp="$(mktemp)"
  curl -fsSL --retry 3 --retry-delay 5 "$1" -o "$tmp"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool --sort-keys "$tmp" >"$2"
  else
    cp "$tmp" "$2"
  fi
  rm -f "$tmp"
  echo "ok  $2"
}

fetch      "$BASE/data/transits.csv"                       data/transits.csv
fetch      "$BASE/data/hormuz-index.csv"                   data/hormuz-index.csv
fetch      "$BASE/data/hormuz-index.csv?granularity=daily" data/hormuz-index-daily.csv
fetch      "$BASE/data/oil.csv"                            data/oil.csv
fetch      "$BASE/data/events.csv"                         data/events.csv
fetch      "$BASE/data/status.csv"                         data/status.csv
fetch_json "$BASE/status"                                  data/status.json
fetch_json "$BASE/api/index"                               data/hormuz-index.json
fetch_json "$BASE/api/v1/transits?history=1&limit=365"     data/transits.json

echo "done"
