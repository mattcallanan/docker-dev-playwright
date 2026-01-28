#!/bin/bash
set -e

# Create symlink to /app/node_modules if it doesn't exist in the working directory
if [ ! -e "$PWD/node_modules" ]; then
    ln -s /app/node_modules "$PWD/node_modules"
fi

# Execute the provided command
exec "$@"
