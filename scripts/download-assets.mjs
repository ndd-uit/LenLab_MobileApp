import { readFileSync, mkdirSync, statSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { resolve } from 'node:path';
const root = resolve(import.meta.dirname, '..');
const target = resolve(root, 'packages/lenlab_shared/assets/figma');
mkdirSync(target, { recursive: true });
const assets = JSON.parse(readFileSync(resolve(root, '.design/assets.json'), 'utf8'));
const failed = [];
async function worker() {
  for (;;) {
    const item = assets.pop();
    if (!item) return;
    const path = resolve(target, item.file);
    try { if (statSync(path).size) continue; } catch {}
    await new Promise(resolve => {
      const child = spawn('curl.exe', ['-f', '-L', '-s', '--retry', '2', '-o', path, item.url]);
      child.on('exit', code => { if (code) failed.push(item.file); resolve(); });
    });
  }
}
await Promise.all(Array.from({ length: 12 }, worker));
console.log(JSON.stringify({ failed }));
if (failed.length) process.exitCode = 1;
