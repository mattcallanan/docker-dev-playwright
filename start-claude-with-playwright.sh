#!/bin/bash

# Start interactive Claude Code CLI session in Docker with Playwright server

SCRIPT_DIR="$(dirname "$0")"

# Start Playwright server and capture token
TOKEN=$("$SCRIPT_DIR/start-playwright-server.sh")

if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to get Playwright token" >&2
  exit 1
fi

echo "Playwright server started with token: $TOKEN"
echo "Starting Claude Code CLI..."
echo ""

# Ensure ~/.claude exists on host for session persistence
mkdir -p "$HOME/.claude"

# Run Claude in Docker with:
# - Current directory mounted at same path (for /resume compatibility)
# - ~/.claude mounted for session persistence
# - Playwright token available as environment variable
# - Host networking for Playwright server connection
docker run --rm -it \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  -v "$HOME/.claude:/home/dev/.claude" \
  --add-host=host.docker.internal:host-gateway \
  -e PLAYWRIGHT_TOKEN="$TOKEN" \
  docker-dev-playwright claude --dangerously-skip-permissions
