const path = require("path");
const puppeteer = require("../../content/node_modules/puppeteer");

const root = __dirname;
const output = path.join(root, "exports", "05-private-clear-1290x2796.png");

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
      #shot-5 {
        padding-top: 142px;
      }

      #shot-5 .brand-row {
        margin-bottom: 54px;
      }

      #shot-5 h1 {
        font-size: 98px;
        line-height: 0.98;
        width: 1000px;
      }

      #shot-5 .support {
        font-size: 42px;
        line-height: 1.2;
        width: 940px;
        margin-bottom: 62px;
      }

      #shot-5 .stage {
        height: 1858px;
      }

      #shot-5 .phone {
        width: 835px;
        height: 1810px;
        transform: translateX(-82px);
      }

      #shot-5 .app {
        padding-left: 46px;
        padding-right: 46px;
      }

      #shot-5 .page-title {
        font-size: 50px;
      }

      #shot-5 .page-copy {
        font-size: 25px;
        margin-bottom: 24px;
      }

      #shot-5 .privacy-item {
        grid-template-columns: 58px 1fr;
        padding: 20px;
      }

      #shot-5 .privacy-title {
        font-size: 25px;
      }

      #shot-5 .privacy-sub {
        font-size: 19px;
        line-height: 1.25;
      }

      #shot-5 .label {
        font-size: 25px;
      }

      #shot-5 .variant-title {
        font-size: 24px;
      }

      #shot-5 .variant-sub {
        font-size: 19px;
      }

      #shot-5 .corner-note {
        right: 82px;
        bottom: 92px;
        width: 286px;
        font-size: 26px;
      }
    `,
  });

  const element = await page.$("#shot-5");
  if (!element) throw new Error("Missing #shot-5");
  await element.screenshot({ path: output, omitBackground: false });
  await browser.close();
  console.log(output);
})();
