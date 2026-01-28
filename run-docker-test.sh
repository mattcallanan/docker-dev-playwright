#!/bin/bash

# Start Playwright server and run test in Docker container

SCRIPT_DIR="$(dirname "$0")"

# Start server and capture token
TOKEN=$("$SCRIPT_DIR/start-playwright-server.sh")

if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to get Playwright token" >&2
  exit 1
fi

echo "Playwright server started with token: $TOKEN"
echo "Running test in Docker..."
echo ""

# Ensure ~/.claude exists on host for Claude Code CLI session persistence
mkdir -p "$HOME/.claude"

# Run the docker command with the token
# Mount ~/.claude for Claude Code CLI session persistence
docker run --rm \
  -v "$PWD:/workspace" \
  -v "$HOME/.claude:/home/dev/.claude" \
  --add-host=host.docker.internal:host-gateway \
  -e PLAYWRIGHT_TOKEN="$TOKEN" \
  docker-dev-playwright npx tsx playwright-example.ts
