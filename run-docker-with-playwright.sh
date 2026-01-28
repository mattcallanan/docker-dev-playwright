#!/bin/bash

# Start Playwright server and run Docker container interactively

SCRIPT_DIR="$(dirname "$0")"

# Start server and capture token
TOKEN=$("$SCRIPT_DIR/start-playwright-server.sh")

if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to get Playwright token" >&2
  exit 1
fi

echo "Playwright server started with token: $TOKEN"
echo ""
echo "=========================================="
echo "INSTRUCTIONS"
echo "=========================================="
echo ""
echo "Once inside the container, run:"
echo ""
echo "  npx tsx playwright-example.ts"
echo ""
echo "Expected output:"
echo "  - Browser connects to Playwright server"
echo "  - Navigates to https://example.com"
echo "  - Prints the page title (should be 'Example Domain')"
echo ""
echo "=========================================="
echo ""
echo "Starting interactive Docker container..."
echo ""

# Ensure ~/.claude exists on host for Claude Code CLI session persistence
mkdir -p "$HOME/.claude"

# Run the docker command interactively with the token
# Mount ~/.claude for Claude Code CLI session persistence
# Mount workspace at same path as host so Claude sessions can resume correctly
docker run --rm -it \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  -v "$HOME/.claude:/home/dev/.claude" \
  --add-host=host.docker.internal:host-gateway \
  -e PLAYWRIGHT_TOKEN="$TOKEN" \
  docker-dev-playwright
