const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "01-main-hook-clear-1290x2796.png");

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

  await page.addStyleTag({
    content: `
      #shot-1 {
        padding-top: 142px;
      }

      #shot-1 .brand-row {
        margin-bottom: 54px;
      }

      #shot-1 h1 {
        font-size: 98px;
        line-height: 0.98;
        width: 1080px;
      }

      #shot-1 .support {
        font-size: 42px;
        margin-bottom: 56px;
      }

      #shot-1 .stage {
        height: 1858px;
      }

      #shot-1 .phone {
        width: 850px;
        height: 1840px;
        transform: translateX(-80px);
      }

      #shot-1 .app {
        padding-left: 48px;
        padding-right: 48px;
      }

      #shot-1 .page-title {
        font-size: 52px;
      }

      #shot-1 .page-copy {
        font-size: 25px;
      }

      #shot-1 .label {
        font-size: 25px;
      }

      #shot-1 .textarea {
        font-size: 22px;
        line-height: 1.38;
      }

      #shot-1 .button {
        font-size: 25px;
      }

      #shot-1 .privacy-note {
        font-size: 22px;
      }

      #shot-1 .corner-note {
        right: 82px;
        bottom: 92px;
        width: 280px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-1");
  if (!element) throw new Error("Missing #shot-1");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
