# Docker Dev Environment with Playwright

A Docker-based development environment with Playwright, TypeScript (tsx), SDKMAN, Kotlin, Gradle, Python tooling, and more.

## Prerequisites

- Docker Desktop installed and running
- Node.js and npm installed (for local Playwright server)

## Quick Start

### Build the Docker Image

```bash
docker build -t docker-dev-playwright .
```

### Run a Playwright Script

```bash
docker run --rm -v "$PWD:/workspace" --dns 8.8.8.8 docker-dev-playwright npx tsx playwright-example.ts
```

### Interactive Shell

```bash
docker run -it --rm -v "$PWD:/workspace" --dns 8.8.8.8 docker-dev-playwright bash
```

## Running Playwright on Local Machine

If you want to run Playwright server on your host machine and connect from Docker (or other clients):

### 1. Start Playwright Server Locally

```bash
npx playwright launch-server --browser firefox --config launch-server-config.json
```

The server will start on `http://localhost:9323` and output a WebSocket endpoint URL like:
```
Listening on ws://127.0.0.1:9323/<token>
```

### 2. Configure Your Script

Update your TypeScript file to connect to the server:

```typescript
import { firefox } from '@playwright/test';

const browser = await firefox.connect({
  wsEndpoint: 'ws://host.docker.internal:9323/<token>'
});

const context = await browser.newContext();
const page = await context.newPage();
await page.goto('https://example.com');
console.log('Page title:', await page.title());
```

**Note:** When running the Playwright server locally, make sure to set `wsHost: "0.0.0.0"` in `launch-server-config.json` to allow connections from Docker.

## Running Playwright in Docker Container

The simpler approach is to launch the browser directly within the container (no separate server needed).

### Example Script (playwright-example.ts)

```typescript
import { firefox } from '@playwright/test';

// Launch browser directly in the container
const browser = await firefox.launch({
  headless: true
});

const context = await browser.newContext({
  ignoreHTTPSErrors: true
});
const page = await context.newPage();

await page.goto('https://example.com');
console.log('Page title:', await page.title());

await browser.close();
```

### Run the Example

```bash
docker run --rm -v "$PWD:/workspace" --dns 8.8.8.8 docker-dev-playwright npx tsx playwright-example.ts
```

Output:
```
Page title: Example Domain
```

## Interactive Development

### Start an Interactive Bash Session

```bash
docker run -it --rm -v "$PWD:/workspace" --dns 8.8.8.8 docker-dev-playwright bash
```

### Once Inside the Container

Run TypeScript files with tsx:
```bash
npx tsx playwright-example.ts
```

Use Kotlin:
```bash
kotlin -version
kotlinc hello.kt -include-runtime -d hello.jar
java -jar hello.jar
```

Use Gradle:
```bash
gradle --version
gradle init
```

Use Python tools:
```bash
poetry --version
virtualenv --version
python3 --version
```

Run Playwright tests:
```bash
npx playwright test
```

Install additional npm packages:
```bash
npm install <package-name>
```

## Visual Browser Interaction

To see the browser in action (not headless), you'll need to run Playwright on your local machine with a display.

### On macOS/Linux with X11

1. Install XQuartz (macOS) or ensure X11 is running (Linux)

2. Allow Docker to connect to X11:
```bash
xhost +localhost
```

3. Run with display forwarding:
```bash
docker run -it --rm \
  -v "$PWD:/workspace" \
  --dns 8.8.8.8 \
  -e DISPLAY=host.docker.internal:0 \
  docker-dev-playwright \
  npx tsx playwright-example.ts
```

4. Update your script to run with `headless: false`:
```typescript
const browser = await firefox.launch({
  headless: false  // Show the browser window
});
```

### Simpler: Run Locally with Visual Browser

For the easiest visual experience, run Playwright directly on your host machine:

1. Install dependencies locally:
```bash
npm install
```

2. Update script to disable headless:
```typescript
const browser = await firefox.launch({
  headless: false
});
```

3. Run locally:
```bash
npx tsx playwright-example.ts
```

You'll see Firefox open, navigate to the page, and then close.

## Configuration Files

### launch-server-config.json

Configuration for Playwright launch-server:
```json
{
  "headless": false,
  "port": 9323,
  "wsHost": "0.0.0.0"
}
```

### package.json

Contains Playwright and tsx dependencies. The container has these pre-installed in `/app/node_modules`.

## Docker Configuration Details

### DNS Resolution

The `--dns 8.8.8.8` flag is needed for proper DNS resolution inside the container.

### Volume Mounting

`-v "$PWD:/workspace"` mounts your current directory to `/workspace` in the container. The entrypoint script automatically symlinks `/app/node_modules` to `/workspace/node_modules`.

### Network Access

- Use `--network=host` on Linux for host network access
- On macOS/Windows, use `host.docker.internal` to access host services
- For internet access, ensure Docker has network connectivity

## Included Tools

- **Node.js 24.x** - JavaScript runtime
- **TypeScript/tsx** - TypeScript execution
- **Playwright 1.58.0** - Browser automation (Chromium, Firefox, WebKit)
- **SDKMAN** - SDK manager for JVM languages
- **Kotlin 2.3.0** - JVM language
- **Gradle 9.3.0** - Build tool
- **Python 3.12** - Python runtime
- **Poetry** - Python dependency management
- **virtualenv** - Python virtual environments
- **pipx** - Python app installer
- **Git** - Version control
- **Build essentials** - Compilers and build tools

## Troubleshooting

### SSL Certificate Errors

The Dockerfile is configured with `npm config set strict-ssl false` and `sdkman_insecure_ssl=true` to handle SSL certificate issues in corporate environments.

### Module Not Found

If you see "Cannot find package" errors, the node_modules symlink may not have been created. The entrypoint script should handle this automatically, but you can manually create it:
```bash
ln -s /app/node_modules /workspace/node_modules
```

### Browser Not Found

Ensure the Docker image version matches your @playwright/test package version. The Dockerfile uses `mcr.microsoft.com/playwright:v1.58.0-noble`.

### Network Connectivity Issues

If the container can't reach external sites, ensure:
- Docker has internet access
- DNS is configured: `--dns 8.8.8.8`
- Consider using `ignoreHTTPSErrors: true` in your browser context for SSL issues

## License

MIT
