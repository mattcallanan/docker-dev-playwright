#!/bin/bash

# Start interactive Claude Code CLI session in Docker

# Ensure ~/.claude exists on host for session persistence
mkdir -p "$HOME/.claude"

# Run Claude in Docker with:
# - Current directory mounted at same path (for /resume compatibility)
# - ~/.claude mounted for session persistence
docker run --rm -it \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  -v "$HOME/.claude:/home/dev/.claude" \
  docker-dev-playwright claude --dangerously-skip-permissions
