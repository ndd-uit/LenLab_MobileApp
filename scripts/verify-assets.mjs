import { readFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';
const root = resolve(import.meta.dirname, '..');
const registry = readFileSync(resolve(root, 'packages/lenlab_shared/lib/src/ui/asset_files.dart'), 'utf8');
const files = [...new Set([...registry.matchAll(/'([^']+\.(?:png|svg))'/g)].map(m => m[1]))];
const missing = files.filter(file => {
  try { return statSync(resolve(root, 'packages/lenlab_shared/assets/figma', file)).size === 0; }
  catch { return true; }
});
console.log(JSON.stringify({ registered: files.length, missing }));
if(missing.length) process.exitCode = 1;
