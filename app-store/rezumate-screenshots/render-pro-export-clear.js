const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "06-pro-export-clear-1290x2796.png");

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
      #shot-6 {
        padding-top: 142px;
      }

      #shot-6 .brand-row {
        margin-bottom: 54px;
      }

      #shot-6 h1 {
        font-size: 92px;
        line-height: 0.98;
        width: 1080px;
      }

      #shot-6 .support {
        font-size: 42px;
        line-height: 1.2;
        width: 940px;
        margin-bottom: 62px;
      }

      #shot-6 .stage {
        height: 1858px;
      }

      #shot-6 .phone {
        width: 835px;
        height: 1810px;
        transform: translateX(36px);
      }

      #shot-6 .app {
        padding-left: 46px;
        padding-right: 46px;
      }

      #shot-6 .page-title {
        font-size: 50px;
      }

      #shot-6 .page-copy {
        font-size: 25px;
        margin-bottom: 24px;
      }

      #shot-6 .variant {
        grid-template-columns: 60px 1fr auto;
        padding: 19px;
      }

      #shot-6 .variant-title {
        font-size: 24px;
      }

      #shot-6 .variant-sub {
        font-size: 19px;
      }

      #shot-6 .label,
      #shot-6 .privacy-title {
        font-size: 25px;
      }

      #shot-6 .privacy-sub {
        font-size: 19px;
      }

      #shot-6 .button {
        font-size: 25px;
      }

      #shot-6 .corner-note {
        left: 82px;
        bottom: 92px;
        width: 286px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-6");
  if (!element) throw new Error("Missing #shot-6");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
