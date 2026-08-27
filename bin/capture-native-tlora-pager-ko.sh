#!/usr/bin/env bash
set -eu

if [ "$#" -lt 4 ] || [ "$#" -gt 6 ]; then
  echo "usage: $0 CONFIG FS_DIR SCREENSHOT LOG [RAW_FIXTURE] [RESTORED_MESSAGE]" >&2
  exit 2
fi

PAGER_CONFIG=$1
PAGER_FS_DIR=$2
PAGER_SCREENSHOT=$3
PAGER_LOG=$4
PAGER_FIXTURE=${5:-}
PAGER_RESTORED=${6:-}
PAGER_BINARY=.pio/build/native-tlora-pager-ko/meshtasticd

mkdir -p "$PAGER_FS_DIR" "$(dirname "$PAGER_SCREENSHOT")" "$(dirname "$PAGER_LOG")"

export MESHTASTIC_LAYOUT_SCREEN=messages
if [ -n "$PAGER_FIXTURE" ]; then
  export MESHTASTIC_TLORA_PAGER_RAW_REPLAY=$PAGER_FIXTURE
fi
if [ -n "$PAGER_RESTORED" ]; then
  export MESHTASTIC_VERIFY_RESTORED_MESSAGE=$PAGER_RESTORED
fi

"$PAGER_BINARY" -c "$PAGER_CONFIG" -d "$PAGER_FS_DIR" >"$PAGER_LOG" 2>&1 &
PAGER_PID=$!
trap 'kill "$PAGER_PID" 2>/dev/null || true' EXIT INT TERM

sleep 6
import -window root "$PAGER_SCREENSHOT"
kill "$PAGER_PID" 2>/dev/null || true
wait "$PAGER_PID" 2>/dev/null || true
trap - EXIT INT TERM
