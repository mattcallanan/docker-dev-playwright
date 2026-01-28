#!/bin/bash

# Start Playwright server and extract the token from its output

FIFO=$(mktemp -u)
mkfifo "$FIFO"
trap "rm -f '$FIFO'" EXIT

# Start playwright server with output to FIFO
npx playwright launch-server --browser firefox --config launch-server-config.json > "$FIFO" 2>&1 &
SERVER_PID=$!

echo "Starting Playwright server (PID: $SERVER_PID)..."
echo ""

# Read from FIFO, extract token when we see it
TOKEN=""
while IFS= read -r line; do
  echo "$line"
  if [[ "$line" == *"Listening on ws://"* ]] && [[ -z "$TOKEN" ]]; then
    # Extract token from URL like ws://127.0.0.1:9323/abc123xyz
    TOKEN=$(echo "$line" | grep -oE 'ws://[^[:space:]]+' | sed 's/.*\///')

    echo ""
    echo "========================================"
    echo "PLAYWRIGHT_TOKEN=$TOKEN"
    echo "========================================"
    echo ""
    echo "Run in another terminal:"
    echo "docker run --rm -v \"\$PWD:/workspace\" --add-host=host.docker.internal:host-gateway -e PLAYWRIGHT_TOKEN=$TOKEN docker-dev-playwright npx tsx playwright-example.ts"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo "========================================"
    echo ""
  fi
done < "$FIFO"

wait $SERVER_PID
