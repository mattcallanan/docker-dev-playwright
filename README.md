# Docker Dev Environment with Playwright

Run automated browser tests from inside a Docker container while watching the browser on your local macOS machine.

## Prerequisites

- Docker Desktop installed and running
- Node.js and npm installed locally (for the Playwright browser server)

## Step-by-Step Instructions

### Step 1: Build the Docker Image

```bash
docker build -t docker-dev-playwright .
```

### Step 2: Install Playwright Locally

Install Playwright on your local machine to run the browser server:

```bash
npm install
npx playwright install firefox
```

### Step 3: Run the Test

Run the test with a single command:

```bash
./run-docker-test.sh
```

This will:
1. Start the Playwright server (Firefox browser opens)
2. Extract the connection token
3. Run the test in Docker with the token

Watch the Firefox browser on your Mac execute the test in real-time.

Server logs are written to `start-playwright-server.log` with ISO 8601 timestamps.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  Your Mac (localhost)                                       │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐│
│  │ Playwright Server   │    │ Firefox Browser (visible)   ││
│  │ (ws://0.0.0.0:9323) │───▶│                             ││
│  └─────────────────────┘    └─────────────────────────────┘│
│           ▲                                                 │
└───────────│─────────────────────────────────────────────────┘
            │ WebSocket connection via host.docker.internal
┌───────────│─────────────────────────────────────────────────┐
│  Docker Container                                           │
│           │                                                 │
│  ┌────────┴────────────┐                                    │
│  │ playwright-example  │                                    │
│  │ .ts (test script)   │                                    │
│  └─────────────────────┘                                    │
└─────────────────────────────────────────────────────────────┘
```

## Interactive Development

Start the Playwright server and capture the token:

```bash
TOKEN=$(./start-playwright-server.sh)
```

Then start an interactive shell:

```bash
docker run -it --rm -v "$PWD:$PWD" -w "$PWD" --add-host=host.docker.internal:host-gateway -e PLAYWRIGHT_TOKEN="$TOKEN" docker-dev-playwright bash
```

Run your test scripts inside the container:

```bash
npx tsx playwright-example.ts
```

## Claude Code CLI

The Docker image includes Claude Code CLI. To run an interactive Claude session:

```bash
docker run --rm -it -v "$PWD:$PWD" -w "$PWD" -v "$HOME/.claude:/home/dev/.claude" docker-dev-playwright claude --dangerously-skip-permissions
```

This mounts:
- Your current directory at the same path (so `/resume` works correctly)
- Your `~/.claude` directory for session persistence

## Configuration

### launch-server-config.json

```json
{
  "headless": false,
  "port": 9323,
  "wsHost": "0.0.0.0"
}
```

- `headless: false` - Shows the browser window so you can watch tests run
- `port: 9323` - The port the WebSocket server listens on
- `wsHost: "0.0.0.0"` - Allows connections from Docker (not just localhost)

## Troubleshooting

### Connection Refused

Make sure the Playwright server is running on your Mac and `wsHost` is set to `"0.0.0.0"` in `launch-server-config.json`.

### Token Mismatch

Each time you restart the Playwright server, it generates a new token. The scripts handle this automatically, but if running manually, get a fresh token with `./start-playwright-server.sh`.

### DNS Issues

If the container can't reach external sites, add `--dns 8.8.8.8` to the docker run command.
