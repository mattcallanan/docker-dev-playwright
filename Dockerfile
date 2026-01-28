FROM mcr.microsoft.com/playwright:v1.58.0-noble

ENV DEBIAN_FRONTEND=noninteractive

# System + Python base tooling
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    zip \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    openjdk-21-jdk \
    ca-certificates \
    sudo \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root dev user
RUN useradd -m dev && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev

# Install Node.js dependencies in /app (won't be overwritten by volume mount)
WORKDIR /app
COPY --chown=dev:dev package.json ./
RUN npm config set strict-ssl false && npm install

# Set NODE_PATH so node can find modules from /app/node_modules
ENV NODE_PATH=/app/node_modules

# Set working directory to /workspace for user files
WORKDIR /workspace

# SDKMAN + Kotlin + Gradle
ENV sdkman_insecure_ssl=true
RUN bash <<'EOF'
set -e
export SDKMAN_DIR="/home/dev/.sdkman"
# Temporarily configure curl to skip SSL verification
echo "insecure" > ~/.curlrc
curl -fsSL "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install kotlin
sdk install gradle
rm ~/.curlrc
EOF

# Python dev tools via pipx (PEP 668–safe)
RUN pipx install poetry
RUN pipx install virtualenv

# Install Claude Code CLI globally (needs root for /usr/lib/node_modules)
USER root
RUN npm config set strict-ssl false && npm install -g @anthropic-ai/claude-code
USER dev

# PATH setup
ENV PATH="/home/dev/.local/bin:/home/dev/.sdkman/bin:$PATH"

# Copy and setup entrypoint script
COPY --chown=dev:dev docker-entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
USER dev

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "bash" ]
