import { firefox } from '@playwright/test';

const browser = await firefox.connect({
  wsEndpoint: 'ws://host.docker.internal:9323'
});

const context = await browser.newContext();
const page = await context.newPage();

await page.goto('https://example.com');

