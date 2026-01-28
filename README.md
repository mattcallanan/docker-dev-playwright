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

### Step 3: Start the Playwright Browser Server

On your local machine, start the Playwright server using the helper script:

```bash
./start-playwright-server.sh
```

This will launch a visible Firefox browser and display the token:

```
Starting Playwright server (PID: 12345)...

Listening on ws://127.0.0.1:9323/abc123xyz

========================================
PLAYWRIGHT_TOKEN=abc123xyz
========================================

Run in another terminal:
docker run --rm -v "$PWD:/workspace" --add-host=host.docker.internal:host-gateway -e PLAYWRIGHT_TOKEN=abc123xyz docker-dev-playwright npx tsx playwright-example.ts
```

### Step 4: Run the Test from Docker

In a new terminal, copy and run the docker command shown in Step 3.

Watch the Firefox browser on your Mac execute the test in real-time.

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

Start an interactive shell inside the container (using the token from `./start-playwright-server.sh`):

```bash
docker run -it --rm -v "$PWD:/workspace" --add-host=host.docker.internal:host-gateway -e PLAYWRIGHT_TOKEN=abc123xyz docker-dev-playwright bash
```

Then run your test scripts as needed:

```bash
npx tsx playwright-example.ts
```

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

Each time you restart the Playwright server, it generates a new token. Update the `PLAYWRIGHT_TOKEN` environment variable with the new token.

### DNS Issues

If the container can't reach external sites, add `--dns 8.8.8.8` to the docker run command.
