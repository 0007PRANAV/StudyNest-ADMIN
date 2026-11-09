// Static build for the StudyNest admin dashboard.
// Vercel serves the files from dist/ (see vercel.json).
const fs = require('fs');
const path = require('path');

const out = path.join(__dirname, 'dist');
fs.rmSync(out, { recursive: true, force: true });
fs.mkdirSync(out, { recursive: true });

for (const file of ['index.html', 'manifest.webmanifest']) {
  const src = path.join(__dirname, file);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, path.join(out, file));
    console.log('copied', file);
  }
}

console.log('StudyNest Admin build complete -> dist/');
