const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "03-improve-resume-clear-1290x2796.png");

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
      #shot-3 {
        padding-top: 142px;
      }

      #shot-3 .brand-row {
        margin-bottom: 54px;
      }

      #shot-3 h1 {
        font-size: 98px;
        line-height: 0.98;
        width: 1040px;
      }

      #shot-3 .support {
        font-size: 42px;
        line-height: 1.2;
        width: 940px;
        margin-bottom: 60px;
      }

      #shot-3 .stage {
        height: 1858px;
        margin-top: 0;
      }

      #shot-3 .phone {
        width: 840px;
        height: 1820px;
        transform: translateX(-52px);
      }

      #shot-3 .app {
        padding-left: 46px;
        padding-right: 46px;
      }

      #shot-3 .page-title {
        font-size: 52px;
      }

      #shot-3 .page-copy {
        font-size: 25px;
        margin-bottom: 24px;
      }

      #shot-3 .card {
        margin-bottom: 22px;
      }

      #shot-3 .bullet-card {
        padding: 22px;
      }

      #shot-3 .bullet-head {
        font-size: 20px;
      }

      #shot-3 .bullet-text {
        font-size: 22px;
        line-height: 1.34;
      }

      #shot-3 .new {
        padding: 17px;
      }

      #shot-3 .label {
        font-size: 25px;
      }

      #shot-3 .button {
        font-size: 25px;
      }

      #shot-3 .line.black {
        height: 20px;
      }

      #shot-3 .line {
        height: 18px;
      }

      #shot-3 .line.yellow {
        height: 26px;
      }

      #shot-3 .corner-note {
        right: 82px;
        bottom: 92px;
        width: 296px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-3");
  if (!element) throw new Error("Missing #shot-3");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
