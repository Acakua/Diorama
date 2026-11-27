# G4 — Kitchen recipes: turn raw stores into dishes that sell and help at night

## Objective
The island makes raw goods (firewood, pumpkins, fish, eggs, potions) and night crystals. Add a
**kitchen** to Mun's ledger: the player queues **recipes** that Linh cooks from the stores. Dishes
sell for more in paper-crane orders, and one dish eaten before bed **strengthens the night
defence**. This links the farm half and the fight half of the game (`design/game-brief.md`,
"Phạm vi v2"). Cosy, no fail state, no timers the player must watch.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: `const W`, `saveW`, `loadW`; `const Orders` (templates `ORDER_T`, keys `K`,
  units `UNIT`, `can`, `send`, `render`); `const Upg` (buy/can/render pattern); `const Def`
  (`begin`, `sim`, tower damage `5+4*(t-1)`, charm damage, `W.def.cry`); `const Away` (away
  yields and summary lines); the ledger markup; `logJ`, `note`; `window.__dao`.

## Files you may change
`dao-coi-nuoc.html` only: `const W` (add `dish:{}` and `meal:null`), `saveW`, `loadW`, a **new**
`const Kitchen={...}` right after `const Def={...}`, `Orders` (add dish keys and 4 templates),
`Def.begin` and `Def.sim` (read the meal buff only), `Away.init`/`Away.show` (cook queued
recipes while away), the ledger markup (one new section after "Nhờ Linh"), new `#ledger …` CSS,
the boot line (`Kitchen.build();` after `Def.build();`), `Mun.render` (call
`Kitchen.render(force)`), `window.__dao` (`get kitchen(){return Kitchen},`).

## Spec
- **Recipes** (`const RECIPE`), each `{name, need:{...}, cook:<island hours>, sell:<coins>, desc}`:

| key | name | needs | cook | sells | effect if eaten before night |
|---|---|---|---|---|---|
| `soup` | Súp bí | 1 bí, 1 củi | 1 h | 26 | tower damage +20 % |
| `pie` | Bánh cá | 2 cá, 1 trứng, 1 củi | 1.5 h | 34 | charm fires 25 % faster |
| `omelet` | Trứng chiên thảo mộc | 3 trứng, 1 củi | 0.5 h | 22 | ward max +20 % |
| `tea` | Trà sương | 1 thuốc, 3 tinh thể | 1 h | 40 | wraiths climb 15 % slower |

- **Dish stores**: `W.dish={soup:0,pie:0,omelet:0,tea:0}` (integers 0–99, saved/validated).
- **Queue**: up to 3 recipes queued (`W.cookQ=[{k, left:<island hours>}]`, saved). Queuing takes
  the ingredients **at once** (`Kitchen.can(k)` gives a Vietnamese reason if short, e.g.
  `'Còn thiếu 1 quả bí.'`; crystals come from `W.def.cry`). The first item counts down in island
  hours each frame (`dt*speed*24/DAY_S`, only while `speed>0`); when done: `W.dish[k]++`,
  `logJ('Linh nấu xong '+name+'. Mun cất vào chạn.')`, next item starts.
- **Supper choice**: a selector "Bữa tối trước đêm" lists dishes the player has (or "Không").
  At the start of each night (`Def.begin`), if `W.meal` names a dish with `W.dish[k]>=1`, use one:
  `W.dish[k]--`, store `Def.buff=k` for that night and `note('Linh ăn '+name+' trước khi lên vòm.')`;
  otherwise `Def.buff=null`. `W.meal` persists (the player sets it once). `simNight()` uses the same.
- **Buff hooks in `Def.sim`** (read-only use of `this.buff`): soup → tower damage ×1.2; pie →
  charm cooldown ×0.75; omelet → `ward.max` and starting hp ×1.2 (apply in `begin`); tea → climb
  speed ×0.85.
- **Selling**: add dish keys to `Orders.K`/`UNIT` (`'bát súp bí'`, `'chiếc bánh cá'`,
  `'đĩa trứng chiên'`, `'ấm trà sương'`) reading `W.dish[k]` instead of `W[k]` (make `Orders.can`
  and `send` use a small getter/setter so dish keys go to `W.dish`). Add 4 templates paying
  `sell × count × 1.2`, e.g. `'Quán trọ đảo Mây Thấp'` 2 soup; `'Đoàn lữ khách gió bấc'` 1 pie +
  1 omelet; `'Đài thiên văn đảo Đá'` 1 tea; `'Nhà chòi lũ trẻ đảo Bèo'` 2 omelet.
  Dish templates only roll when the player has cooked that dish at least once (`W.dishEver[k]`).
- **Away**: queued recipes finish during away time (by island hours), and the summary lists
  "Bếp nấu xong 2 bát súp bí."
- **Ledger UI** — section "Bếp và chạn": dish counts; the queue with time left
  ("Súp bí · còn 40 phút"); a button per recipe `Nấu · <needs>` (disabled with reason); the
  supper selector as a `.seg` of buttons. Signature-based redraw like the others.

## Constraints
- No 3D work. No allocation per frame beyond the queue countdown. Old saves load with empty dish
  stores, empty queue and `meal:null`.
- Do not change existing order templates, prices, Def costs or difficulty constants.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block, plus one headless check: `simNight()` held/kills at `lvl=12` with the
default loadout, with and without each buff (5 runs each).
