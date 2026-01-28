#!/bin/bash
set -e

# Create symlink to /app/node_modules if it doesn't exist in /workspace
if [ ! -e "/workspace/node_modules" ]; then
    ln -s /app/node_modules /workspace/node_modules
fi

# Execute the provided command
exec "$@"
