import { readFileSync, writeFileSync } from 'fs';
import { JSDOM } from 'jsdom';

const path = process.argv[2] || 'docs/index.html';
const html = readFileSync(path, 'utf8');
const dom = new JSDOM(html);
const doc = dom.window.document;

const title = doc.querySelector('title');
const h1 = doc.querySelector('h1');

const lines = ['# Next Development Steps', ''];

if (!title || title.textContent.trim() === '') {
  lines.push('- Add a meaningful <title> to the homepage.');
} else {
  lines.push(`- The page title is "${title.textContent}". Consider expanding content.`);
}

if (!h1) {
  lines.push('- Include a top-level heading.');
}

lines.push('- Enhance layout and styling.');

writeFileSync('devplan.nextsteps.md', lines.join('\n') + '\n');
