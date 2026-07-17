const { spawn } = require('child_process');
const express = require('express');
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

// Configuration
const FPS = 60;
const PORT = 3000;

// Parse concept argument
const args = process.argv.slice(2);
let concept = 1;
for (const arg of args) {
  if (arg.startsWith('--concept=')) {
    concept = parseInt(arg.split('=')[1], 10);
  }
}
if (concept !== 1 && concept !== 2) {
  console.log('Invalid concept. Defaulting to Concept 1.');
  concept = 1;
}

const outputFilename = `concept_${concept}.mp4`;
const outputPath = path.join(__dirname, outputFilename);

async function startServer() {
  const app = express();
  app.use('/gsap', express.static(path.join(__dirname, 'node_modules', 'gsap', 'dist')));
  app.use('/brand-assets', express.static(path.join(__dirname, '..', 'assets')));
  app.use(
    '/promo-screens',
    express.static('/Users/batman/Desktop/patterns-promo'),
  );
  app.use(express.static(path.join(__dirname, 'public')));
  return new Promise((resolve) => {
    const server = app.listen(PORT, () => {
      resolve(server);
    });
  });
}

async function run() {
  console.log(`Starting local server on port ${PORT}...`);
  const server = await startServer();
  console.log('Server started.');

  console.log('Launching Puppeteer...');
  const chromePaths = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
    '/Applications/Chromium.app/Contents/MacOS/Chromium'
  ];
  let executablePath = undefined;
  for (const p of chromePaths) {
    if (fs.existsSync(p)) {
      executablePath = p;
      console.log(`Using system Chrome at: ${executablePath}`);
      break;
    }
  }

  const browser = await puppeteer.launch({
    headless: true,
    executablePath,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const page = await browser.newPage();
  
  // Forward browser console logs and errors to terminal
  page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
  page.on('pageerror', err => console.error('BROWSER ERROR:', err.toString()));
  
  // Set resolution to 1080x1920 for 9:16 portrait video
  await page.setViewport({
    width: 1080,
    height: 1920,
    deviceScaleFactor: 1
  });

  const url = `http://localhost:${PORT}/index.html?concept=${concept}`;
  console.log(`Loading page: ${url}`);
  await page.goto(url, { waitUntil: 'load' });

  // Expose a helper to wait for the animation details to load
  const animationDuration = await page.evaluate(async () => {
    // Wait for the window's init or GSAP timeline setup
    return new Promise((resolve) => {
      const check = () => {
        if (window.animationDuration) {
          resolve(window.animationDuration);
        } else {
          setTimeout(check, 100);
        }
      };
      check();
    });
  });

  const duration = parseFloat(animationDuration);
  const totalFrames = Math.ceil(duration * FPS);
  console.log(`Animation duration detected: ${duration}s. Total frames to capture at ${FPS}fps: ${totalFrames}`);

  console.log(`Spawning FFmpeg process to write to: ${outputFilename}...`);
  // FFmpeg command to compile frame-by-frame PNG stream to MP4
  const ffmpeg = spawn('ffmpeg', [
    '-y',                      // Overwrite output file
    '-f', 'image2pipe',        // Input format is a pipe of images
    '-vcodec', 'png',          // Input codec is png
    '-r', FPS.toString(),      // Input frame rate
    '-i', '-',                 // Read from standard input (stdin)
    '-c:v', 'libx264',         // Encode using H.264
    '-pix_fmt', 'yuv420p',     // Pixel format for high compatibility
    '-crf', '18',              // Visual quality level (18 is nearly visually lossless)
    '-preset', 'slow',         // H.264 preset for better compression
    outputPath                 // Output file path
  ]);

  ffmpeg.stderr.on('data', (data) => {
    // FFmpeg log outputs are sent to stderr. We can keep it quiet or log it for debugging.
    // Console.log(`FFmpeg: ${data.toString()}`);
  });

  ffmpeg.on('close', (code) => {
    console.log(`FFmpeg process finished with code ${code}`);
  });

  console.log('Starting frame-by-frame rendering...');
  for (let frame = 0; frame < totalFrames; frame++) {
    // 1. Tell page to seek GSAP timeline to this frame
    await page.evaluate((f, fpsVal) => {
      if (typeof window.seekToFrame === 'function') {
        window.seekToFrame(f, fpsVal);
      }
    }, frame, FPS);

    // 2. Capture screenshot of viewport
    const screenshot = await page.screenshot({
      type: 'png',
      omitBackground: false
    });

    // 3. Write to FFmpeg stdin
    ffmpeg.stdin.write(screenshot);

    // 4. Log progress
    if (frame % 30 === 0 || frame === totalFrames - 1) {
      const percentage = Math.round((frame / totalFrames) * 100);
      console.log(`Progress: frame ${frame}/${totalFrames} (${percentage}%)`);
    }
  }

  console.log('Finished capturing all frames. Closing FFmpeg input pipe...');
  ffmpeg.stdin.end();

  // Wait for FFmpeg process to close fully
  await new Promise((resolve) => {
    ffmpeg.on('close', resolve);
  });

  console.log('Video generated successfully.');
  
  console.log('Cleaning up browser and server...');
  await browser.close();
  server.close();
  console.log('Done! Output video saved to:', outputFilename);
}

run().catch((err) => {
  console.error('Capture script error:', err);
  process.exit(1);
});
