const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use('/gsap', express.static(path.join(__dirname, 'node_modules', 'gsap', 'dist')));
app.use('/brand-assets', express.static(path.join(__dirname, '..', 'assets')));
app.use(
  '/promo-screens',
  express.static('/Users/batman/Desktop/patterns-promo'),
);
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
