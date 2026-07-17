const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "04-keyword-insights-clear-1290x2796.png");

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
      #shot-4 {
        padding-top: 142px;
      }

      #shot-4 .brand-row {
        margin-bottom: 54px;
      }

      #shot-4 h1 {
        font-size: 98px;
        line-height: 0.98;
        width: 990px;
      }

      #shot-4 .support {
        font-size: 42px;
        line-height: 1.2;
        width: 940px;
        margin-bottom: 60px;
      }

      #shot-4 .stage {
        height: 1858px;
      }

      #shot-4 .phone {
        width: 840px;
        height: 1820px;
        transform: translateX(20px);
      }

      #shot-4 .app {
        padding-left: 46px;
        padding-right: 46px;
      }

      #shot-4 .label {
        font-size: 25px;
      }

      #shot-4 .chip {
        font-size: 20px;
        padding: 10px 16px;
      }

      #shot-4 .keyword-row {
        padding: 18px 0;
      }

      #shot-4 .keyword-title {
        font-size: 24px;
      }

      #shot-4 .keyword-sub {
        font-size: 19px;
        line-height: 1.25;
      }

      #shot-4 .textarea {
        font-size: 22px;
        line-height: 1.38;
      }

      #shot-4 .corner-note {
        left: 82px;
        bottom: 92px;
        width: 286px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-4");
  if (!element) throw new Error("Missing #shot-4");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
