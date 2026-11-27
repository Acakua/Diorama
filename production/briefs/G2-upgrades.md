# G2 — Upgrades bought with coins

## Objective
After G1 the player earns coins (`W.coins`) from paper-crane orders. Give them something to buy:
**five upgrades** in Mun's ledger, each bought once, each making one island job yield more. The
first one (a second firewood rack) is visible on the island. Cosy, no fail state
(`design/game-brief.md`, "Core loop" and "Phạm vi v2").

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`:
  - `const W={...}`, `saveW`, `loadW` (about lines 2006–2032).
  - `const Mun={` (ledger object), especially `cant(a)` (uses 18 as the firewood cap), `stock(a)`
    and `render(force)` (shows `'/18'` for firewood).
  - `const Orders={` (added by G1, right after `Mun`): copy its render/signature pattern.
  - `function buildLife(` (about line 2109): `Life.logs` is an `InstancedMesh` of capacity 18 and
    `Life.logSpots` its 18 positions (4 rows × 5 by `WOODPILE`). `updStore()` shows the logs.
  - Production lines (search these exact snippets):
    - firewood: `if(AG.cn%3==0&&W.wood<18){W.wood++;` and `if(W.wood==18)note(`
    - eggs: `W.eggs=(W.eggs||0)+3;` (and its note text "Nhặt được ba quả trứng…", `Mun.got('eggs',3)`)
    - fish: `const c=Math.floor(t/20),u=(t%20)/20;` (one fish per 20 s of fishing)
    - potions: `W.potions=(W.potions||0)+1;` … `Mun.got('brew',1)`
    - pumpkins: `q.g=Math.min(1,q.g+dt*.0085)` (growth while watering)
  - Search for any other literal `18` tied to firewood (`W.wood>=18`, `W.wood<18`, `'/18'`,
    `furn`/journal text "Đống củi đã đầy").

## Files you may change
`dao-coi-nuoc.html` only: `const W` (add `upg:{}`), `saveW`, `loadW`, the production lines listed
above, `Mun.cant`, `Mun.stock`, `Mun.render` (the '/18' label), `buildLife` and `updStore` (log
capacity and spots), the ledger markup (one new section), new `#ledger …` CSS rules, a **new**
`const Upg={...}` placed right after `const Orders={...}`, the boot line with `Orders.build();`
(add `Upg.build();`), `Mun.render` (call `Upg.render(force)` next to `Orders.render(force)`), and
`window.__dao` (add `get upg(){return Upg},`).

## Spec
- `const UPG` (in this order):

| key | name (vi) | cost | effect |
|---|---|---|---|
| `rack` | Giá củi thứ hai | 50 | firewood cap 18 → 30 |
| `coop` | Ổ rơm êm cho gà | 80 | each egg round gives 5 instead of 3 |
| `patch` | Phân bón phép | 120 | pumpkin growth while watering ×1.6 |
| `rod` | Cần câu bạc | 100 | one fish per 13 s instead of 20 s |
| `kettle` | Vạc đồng lớn | 140 | each finished brew gives 2 potions |

  Each entry also has `desc` (one Vietnamese sentence the ledger shows).
- `W.upg` is an object of bought keys (`{rack:1}`). Helper `has(k)` = `!!W.upg[k]`.
- `woodMax()` returns `has('rack')?30:18`. Replace every firewood `18` listed above with
  `woodMax()` (cap checks, the "đầy" note, `Mun.cant`, `Mun.stock`, the ledger label).
- `Life.logs` capacity becomes 30; `Life.logSpots` gets 12 more spots: the same 4-row stacking
  pattern placed **0.75 m further along −z** from the first stack (rows of 5,4,3 → choose so that
  the total is 30). `updStore` keeps showing `min(floor(W.wood), 30)` logs. Logs beyond 18 only
  appear once `rack` is bought (they cannot exist before, since the cap is 18).
- Egg round: `const n=has('coop')?5:3;` → add `n`, `Mun.got('eggs',n)`, note says "năm quả" or
  "ba quả" accordingly.
- Fishing: period `has('rod')?13:20` in place of both `20`s on that line.
- Brew: add `has('kettle')?2:1` potions and `Mun.got('brew',same)`.
- Pumpkin growth: multiply `.0085` by `has('patch')?1.6:1`.
- `Upg.buy(k)`: if not owned and `Math.floor(W.coins)>=cost`: subtract, set `W.upg[k]=1`,
  `logJ('Mun dốc túi xu mua '+name+'. '+desc)`, `note(name+': '+desc,6)`, `updStore()`,
  `saveW()`. `Upg.can(k)` returns `''` or a reason (`'Còn thiếu 30 xu.'`, `'Đã có.'`).
- Ledger UI: new section **after** "Nhờ Linh": `<h3>Nâng cấp</h3><ul id="lUpg"></ul>`. One `li`
  per upgrade: name (bold), desc (small), and either a button `Mua · 50 xu` (disabled with `title`
  = reason when it cannot be bought) or the text `Đã có`. Signature-based redraw like Orders.
- Save: `upg:Object.keys(W.upg)`. Load: keep only known keys; anything else dropped; default `{}`.

## Constraints
- No new materials, no new meshes except the larger `Life.logs` capacity (same geometry and
  material). Everything created at boot.
- Do not change order or task logic other than the firewood cap.
- Exact string replacement only; do not reformat lines you do not change.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.
- `grep -c "W.wood<18\|W.wood>=18\|W.wood==18" dao-coi-nuoc.html` prints `0`.

## Return
The AGENTS.md report block; list every line where you replaced the firewood 18.
