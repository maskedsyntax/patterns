const express = require('express');
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const times = process.argv.slice(2).map(Number).filter(Number.isFinite);
const sampleTimes = times.length ? times : [0.7, 1.7, 3.5, 5.7, 7.5, 8.9, 10.4, 12.8, 14.4];
const outputDir = path.join(__dirname, 'preview-frames');

async function run() {
  fs.mkdirSync(outputDir, { recursive: true });
  const app = express();
  app.use('/gsap', express.static(path.join(__dirname, 'node_modules', 'gsap', 'dist')));
  app.use('/brand-assets', express.static(path.join(__dirname, '..', 'assets')));
  app.use('/promo-screens', express.static('/Users/batman/Desktop/patterns-promo'));
  app.use(express.static(path.join(__dirname, 'public')));
  const server = await new Promise((resolve) => {
    const instance = app.listen(3001, () => resolve(instance));
  });

  const browser = await puppeteer.launch({
    headless: true,
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    args: ['--no-sandbox'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1080, height: 1920, deviceScaleFactor: 1 });
  await page.goto('http://localhost:3001/index.html?concept=1', { waitUntil: 'networkidle0' });

  for (const time of sampleTimes) {
    await page.evaluate((seconds) => window.seekToFrame(Math.round(seconds * 60), 60), time);
    await page.screenshot({ path: path.join(outputDir, `${time.toFixed(1)}.png`) });
  }

  await browser.close();
  server.close();
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
