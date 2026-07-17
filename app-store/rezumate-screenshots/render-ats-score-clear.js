const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "02-ats-score-clear-1290x2796.png");

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
      #shot-2 {
        padding-top: 142px;
      }

      #shot-2 .brand-row {
        margin-bottom: 54px;
      }

      #shot-2 h1 {
        font-size: 98px;
        line-height: 0.98;
        width: 1030px;
      }

      #shot-2 .support {
        font-size: 42px;
        line-height: 1.2;
        width: 900px;
        margin-bottom: 62px;
      }

      #shot-2 .stage {
        height: 1858px;
      }

      #shot-2 .phone {
        width: 840px;
        height: 1820px;
        transform: translateX(36px);
      }

      #shot-2 .app {
        padding-left: 46px;
        padding-right: 46px;
      }

      #shot-2 .score-card {
        grid-template-columns: 220px 1fr;
        gap: 34px;
      }

      #shot-2 .score-ring {
        width: 210px;
        height: 210px;
      }

      #shot-2 .score-inner {
        width: 138px;
        height: 138px;
        font-size: 52px;
      }

      #shot-2 .score-title {
        font-size: 36px;
      }

      #shot-2 .score-copy {
        font-size: 23px;
      }

      #shot-2 .label {
        font-size: 25px;
      }

      #shot-2 .metric .num {
        font-size: 35px;
      }

      #shot-2 .metric .name {
        font-size: 20px;
      }

      #shot-2 .chip {
        font-size: 20px;
        padding: 10px 16px;
      }

      #shot-2 .diagnosis strong {
        font-size: 24px;
      }

      #shot-2 .diagnosis span {
        font-size: 20px;
      }

      #shot-2 .corner-note {
        left: 82px;
        bottom: 92px;
        width: 286px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-2");
  if (!element) throw new Error("Missing #shot-2");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
