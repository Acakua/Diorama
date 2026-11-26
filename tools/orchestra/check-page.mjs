// Syntax-check every inline <script type="module"> (and classic inline script) in a page.
//
//   node tools/orchestra/check-page.mjs [dao-coi-nuoc.html]
//
// Prints one line per script ("ok script N (bytes)" or "FAIL script N: <error>")
// and a last line "N failed". Exit 1 when any script fails. A parse check is not a
// run: the page must still be opened and looked at (RUNBOOK section 7).
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { spawnSync } from 'node:child_process';

const file = process.argv[2] || 'dao-coi-nuoc.html';
const html = readFileSync(file, 'utf8');
const re = /<script(\s[^>]*)?>([\s\S]*?)<\/script>/gi;
const dir = mkdtempSync(join(tmpdir(), 'checkpage-'));
let n = 0, failed = 0, m;
while ((m = re.exec(html))) {
	const attrs = m[1] || '', body = m[2];
	if (/\bsrc=/.test(attrs) || /importmap|application\/json/.test(attrs) || !body.trim()) continue;
	n++;
	const ext = /type=["']?module/.test(attrs) ? '.mjs' : '.cjs';
	const p = join(dir, `s${n}${ext}`);
	writeFileSync(p, body);
	const r = spawnSync(process.execPath, ['--check', p], { encoding: 'utf8' });
	if (r.status === 0) console.log(`ok script ${n} (${body.length} bytes)`);
	else { failed++; console.log(`FAIL script ${n}: ${(r.stderr || '').split('\n').slice(0, 6).join(' | ')}`); }
}
rmSync(dir, { recursive: true, force: true });
if (n === 0) { console.log('FAIL no inline script found'); failed++; }
console.log(`${failed} failed`);
process.exit(failed ? 1 : 0);
