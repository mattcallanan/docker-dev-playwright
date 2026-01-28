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

