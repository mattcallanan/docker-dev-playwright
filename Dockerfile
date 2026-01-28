FROM mcr.microsoft.com/playwright:v1.57.0-noble

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
WORKDIR /workspace

# Copy package.json and install Node.js dependencies
COPY --chown=dev:dev package.json ./
RUN npm install

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

# PATH setup
ENV PATH="/home/dev/.local/bin:/home/dev/.sdkman/bin:$PATH"

CMD [ "bash" ]
