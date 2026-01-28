import { firefox } from '@playwright/test';

const token = process.env.PLAYWRIGHT_TOKEN;
if (!token) {
  console.error('Error: PLAYWRIGHT_TOKEN environment variable is required');
  process.exit(1);
}

// Connect to browser running on host machine
const browser = await firefox.connect({
  wsEndpoint: `ws://host.docker.internal:9323/${token}`
});

const context = await browser.newContext({
  ignoreHTTPSErrors: true
});
const page = await context.newPage();

await page.goto('https://example.com');
console.log('Page title:', await page.title());

await browser.close();

