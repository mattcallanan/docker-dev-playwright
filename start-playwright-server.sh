#!/bin/bash

# Start Playwright server in background, output token to stdout, log to file

SCRIPT_DIR="$(dirname "$0")"
LOGFILE="$SCRIPT_DIR/start-playwright-server.log"

# Clear log file
> "$LOGFILE"

# Start playwright server with timestamped logging in background
# Use 'script' to force line-buffered output (creates a pseudo-TTY)
# Redirect stdout/stderr to /dev/null so command substitution doesn't wait for this subshell
(
  script -q /dev/null npx playwright launch-server --browser firefox --config "$SCRIPT_DIR/launch-server-config.json" 2>&1 |
  while IFS= read -r line; do
    # Remove carriage returns that script may add
    line="${line//$'\r'/}"
    [ -n "$line" ] && echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") $line" >> "$LOGFILE"
  done
) > /dev/null 2>&1 &

# Wait for the WebSocket URL to appear in the log
TOKEN=""
for i in {1..100}; do  # Wait up to 10 seconds
  if grep -q "ws://.*:[0-9]*/[a-f0-9]" "$LOGFILE" 2>/dev/null; then
    # Extract token from URL, stripping ANSI codes and control chars
    TOKEN=$(grep -oE 'ws://[^[:space:]]+' "$LOGFILE" | head -1 | sed 's/.*\///')
    break
  fi
  sleep 0.1
done

if [[ -z "$TOKEN" ]]; then
  echo "Error: Playwright server failed to start" >&2
  exit 1
fi

echo "$TOKEN"
exit 0
