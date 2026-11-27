# G7 — A market boat for surplus, crystals for coins, and island goals that finish a chapter

## Objective
A playtest of the loop (G1–G6) found three holes:
1. **Coins stop mattering.** All coin sinks (5 upgrades = 490 xu, 2 towers = 180 xu) are bought in
   about 15 island days; after that coins pile up with nothing to buy.
2. **Surplus is stuck.** At most 2 orders are open; extra eggs, fish and dishes have no outlet.
3. **No direction or ending.** The player never learns what to aim for or when a chapter is done.

Add a **market boat** (sell surplus cheaply, buy crystals with coins) and a list of **island goals**
with rewards, the last of which closes "Chương một" with a gentle finale. No fail state, no timers
(`design/game-brief.md`, "Phạm vi v2"). Also fix the away-time wood drain.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: `const W`, `saveW`, `loadW`; `const Orders` (`K`, `UNIT`, `get`/`spend`
  helpers used by `can`/`send`, `send`); `RECIPE`, `DISHU`, `W.dish`, `W.dishEver`; `const Upg`
  (`has`, `UPG`, buy/can/render pattern); `W.def` (`tw`, `nights`, `cry`, `core`); `const Away`
  (`this.eat`); `const LedgerUI` (`badge`, `open`); the ledger markup (`#lPanel-home`,
  `#lPanel-trade`); `logJ`, `note`, `updStore`, `window.__dao`.

## Files you may change
`dao-coi-nuoc.html` only: `const W` (add `mkt` and `goals`, `sent`), `saveW`, `loadW` (validate),
`Orders.send` (one line: `W.sent++`), `Away.init` (only the wood eaten per evening: 2 → 1), the
ledger markup (one section at the **top** of `#lPanel-home`, one section at the **end** of
`#lPanel-trade`), new `#ledger …` CSS, a **new** `const Market={...}` and a **new**
`const Goals={...}` placed right after `const LedgerUI={...}`, `LedgerUI.badge` (also light the dot
for a claimable goal, on `#bLedger` and the "Nhà" tab; opening "Nhà" clears that tab's dot), the
boot line (`Market.build();Goals.build();` before `LedgerUI.build();`), `Mun.render` (call
`Market.render(force);Goals.render(force);` next to the others), `window.__dao`
(`get market(){return Market},get goals(){return Goals},`).
Do not change order templates, upgrade prices, `Def` rules or costs, or recipes.

## Spec

### Market boat — section "Thuyền chợ" at the end of tab "Buôn bán"
- Note line: "Thuyền chợ ghé mỗi ngày, mua rẻ hàng dư. Đơn hạc giấy vẫn trả hời hơn."
- **Sell**: one row per good the player has (`>0`): name, count, unit price, buttons `Bán 1` and
  `Bán 5` (the second disabled if fewer than 5 or the daily room is under 5). Prices (xu each):
  wood 1, eggs 2, fish 3, stock 4, potions 7; dishes `floor(RECIPE[k].sell*0.5)` (soup 13, pie 17,
  omelet 11, tea 20). Goods read and write through the same getter/setter `Orders` uses, so dish
  keys go to `W.dish`.
- **Daily room**: at most 15 items sold per island day: `W.mkt={day,n}`; when `W.mkt.day!==W.day`
  reset `n=0`. Show "Hôm nay thuyền còn nhận N món." Disabled buttons carry a Vietnamese `title`.
- **Buy crystals**: a row "Túi tinh thể · 10 tinh thể" with button `Mua · 40 xu`
  (`W.coins>=40`; adds 10 to `W.def.cry`; no daily limit).
- Each sale/buy: `updStore()`, `saveW()`, one short `logJ` line per click
  (e.g. "Mun bán 5 quả trứng cho thuyền chợ, được 10 xu.").

### Island goals — section "Mục tiêu đảo" at the top of tab "Nhà"
Goals are checked from existing state (no new per-frame work; check inside `render`, which is
signature-based). Each is `{id, text, need:()=>[have, want], gift:{coins?, cry?, core?}}`:

| # | id | text | progress | gift |
|---|---|---|---|---|
| 1 | `first-order` | Gửi đơn hạc giấy đầu tiên | `W.sent`/1 | 10 xu |
| 2 | `first-upg` | Mua món nâng cấp đầu tiên | upgrades owned/1 | 10 tinh thể |
| 3 | `first-dish` | Nấu món đầu tiên trong bếp | dishes ever cooked (count of `W.dishEver`)/1 | 15 xu |
| 4 | `nights-3` | Giữ vòm cổ ngữ qua 3 đêm | `W.def.nights`/3 | 20 xu |
| 5 | `tower-2` | Dựng tháp thứ hai | built towers/2 | 30 tinh thể |
| 6 | `orders-15` | Gửi 15 đơn hạc giấy | `W.sent`/15 | 60 xu |
| 7 | `dishes-4` | Nấu đủ bốn món | `W.dishEver`/4 | 40 tinh thể |
| 8 | `upg-5` | Mua đủ năm món nâng cấp | upgrades/5 | 80 tinh thể |
| 9 | `tower-3` | Dựng đủ ba tháp | towers/3 | 1 lõi sương |
| 10 | `nights-14` | Giữ vòm cổ ngữ qua 14 đêm | `W.def.nights`/14 | 150 tinh thể |

- Show the **first three unclaimed** goals with text, a small progress `have/want`, the gift, and a
  button `Nhận quà` when met (else no button). Below them one line "Đã xong X/10 mục tiêu."
- Claiming: add the gift, push the id to `W.goals` (saved; validate as an array of known ids),
  `logJ('Mun đánh dấu xong: '+text+'.')`, `note('Xong mục tiêu: '+text+' · '+giftText,5)`,
  `updStore()`, `saveW()`.
- **Finale** when all 10 are claimed (once): `logJ('Chương một khép lại: đảo Cối Nước đã yên bình. Linh và Mun cứ thế sống tiếp, ngày qua ngày.')`,
  `note(...)` of the same text for 10 s, and the section then shows
  "Chương một đã xong. Người giữ đảo: Mun." plus the earned count. The game keeps running.
- Old saves: `W.sent` starts at 0 (do not try to reconstruct), `W.goals=[]`, `W.mkt={day:W.day,n:0}`.

### Away fix
In `Away.init`, Linh burns **1** firewood per evening crossed (was 2); pumpkins unchanged.

## Constraints
- No 3D. Nothing new per frame (the existing 1 s `LedgerUI` interval may call `Goals.ready()`, a
  cheap check returning whether any shown goal is claimable). All text Vietnamese.
- Reuse the `.seg`/button styles; the goal rows look like upgrade rows. Keyboard reachable.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block.
