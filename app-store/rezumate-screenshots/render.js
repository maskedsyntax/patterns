const fs = require("fs");
const path = require("path");

const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const outDir = path.join(root, "exports");
fs.mkdirSync(outDir, { recursive: true });

const shots = [
  "01-tailor-your-resume-before-you-apply",
  "02-see-what-your-resume-is-missing",
  "03-improve-weak-bullets-instantly",
  "04-match-the-roles-keywords",
  "05-private-by-design",
  "06-save-variants-export-clean-pdfs",
];

(async () => {
  const browser = await puppeteer.launch({
    headless: "new",
    executablePath: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
    defaultViewport: { width: 1290, height: 2796, deviceScaleFactor: 1 },
  });

  const page = await browser.newPage();
  await page.goto(`file://${path.join(root, "index.html")}`, {
    waitUntil: "networkidle0",
  });

  await page.evaluate(async () => {
    await document.fonts.ready;
  });

  for (let i = 0; i < shots.length; i += 1) {
    const selector = `#shot-${i + 1}`;
    const element = await page.$(selector);
    if (!element) throw new Error(`Missing ${selector}`);
    await element.screenshot({
      path: path.join(outDir, `${shots[i]}.png`),
      omitBackground: false,
    });
  }

  await browser.close();
  console.log(`Exported ${shots.length} screenshots to ${outDir}`);
})();
