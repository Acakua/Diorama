# G3 — The island keeps living while you are away, and Mun sums it up

## Objective
Today every reload starts the island at 08:00 of the saved day and nothing happens while the page
is closed. Make the island **keep time while the player is away** (capped at one island day) and,
on return, show **one ledger page "Trong lúc bạn vắng…"** listing what Linh brought in, the orders
that arrived and the island time that passed. This is the idle half of the game: open the page
after a few hours and something has happened. Cosy, no penalties (`design/game-brief.md`).

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`:
  - `const DAY_S=960;let hour=8.0,...` (about line 2407): one island day = 960 real seconds at 1×.
  - The boot line containing `loadW();makePlan();Mun.bind();` (about line 2914).
  - `const W`, `saveW`, `loadW`, `newDay` (about lines 2006–2035), `logJ`, `note`.
  - `const Orders={` (G1): `Orders.newDay()` rolls new orders. `const Upg={` (G2): `has(k)`,
    `woodMax()`.
  - The ledger markup `<aside id="ledger"` and how the ledger opens (search `$('ledger').hidden`).

## Files you may change
`dao-coi-nuoc.html` only: `saveW`, `loadW`, the boot line, a **new** `const Away={...}` placed
right after `const Upg={...}`, the ledger markup (one new block at its top), new `#ledger …` CSS
rules, and `window.__dao` (add `get away(){return Away},`).

## Spec
- **Save the clock:** `saveW` also stores `hour` (rounded to 0.01) and `at:Date.now()`. Also call
  `saveW()` from a `pagehide` listener and every 30 real seconds (one `setInterval`, created once
  in `Away.init`). `loadW` restores `hour` (0–24) when present.
- **Elapsed island time:** in `Away.init()` (called on the boot line **right after `loadW();`**
  and before `makePlan();`): `real = (Date.now()-q.at)/1000` seconds, ignored when the save has no
  `at`, when negative, or when under 60 s. Island hours passed `ih = min(24, real*24/DAY_S)`.
- **Advance:** add `ih` to `hour`; for each midnight crossed, `W.day++` and run the parts of a new
  day that are pure data: `Orders.newDay()` and the task carry-over `W.tasks=W.tasks.filter(t=>!t.done)`.
  Do **not** call the full `newDay()` (it touches meshes not built yet at this point).
- **Yields while away** (deterministic formula, per island hour away, then `Math.floor` at the end
  and clamp to caps):
  - firewood `+0.25/h` (cap `woodMax()`), eggs `+3` per morning (08:00) crossed (`+5` with `coop`),
    fish `+0.15/h` (`×1.5` with `rod`), pumpkins `+1` per 8 h (×1.6 with `patch`, round down),
    potions `+1` per 12 h (`×2` with `kettle`).
  - Linh also eats: firewood `−2` and pumpkins `−1` per evening (19:00) crossed, never below 0.
  - Store the result in `Away.sum = {ih, from:{...}, to:{...}, orders:<count of new orders>}`.
- **Show it:** when `Away.sum` exists and `ih >= 0.5`, after boot open the ledger and show a block
  at its top: `<section id="lAway"><h3>Trong lúc bạn vắng…</h3>…<button id="lAwayOk">Mun biết rồi</button></section>`.
  Lines in Vietnamese, e.g. "Đảo đã trôi qua 7 giờ 30 phút.", "Linh chặt thêm 2 khúc củi, câu
  được 1 con cá, nhặt 3 quả trứng.", "Bếp đã dùng 2 khúc củi và 1 quả bí.", "Có 1 đơn hàng mới
  bằng hạc giấy." Only list non-zero items. The OK button hides the block. Also `logJ` one
  summary line in Mun's voice.
- If the away time hit the 24 h cap, add the line "Mun chỉ ghi được một ngày, phần còn lại Linh
  ngủ quên mất."

## Constraints
- No 3D work. Nothing new per frame. The summary is computed once at boot.
- A save from before this task (no `at`, no `hour`) must load exactly as today (08:00, no summary).
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block. Under RISKS: anything that could make the day counter jump wrongly
or apply the away yields twice (e.g. two tabs, reload loop).
