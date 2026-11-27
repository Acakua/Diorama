# G6 — Ledger tabs, night HUD placement, a first-run guide

## Objective
Mun's ledger now holds seven sections (stores, orders, tasks, ask Linh, upgrades, kitchen,
defence) in one long scrolling column; the night HUD overlaps the hint text in the top-left; an
order's "×" wraps onto its own line; a new player is not told what to do. Make the game easy to
read and to play for a few minutes at a time (`design/game-brief.md`, `design/art-bible.md` §7
"Giao diện" — read by heading).

## Read first
- `AGENTS.md`; `design/art-bible.md` §7.
- `dao-coi-nuoc.html`: the HUD markup `<div id="hud">` / `.top` / `.hintWrap` (about line 99) and
  its CSS (`#hud`, `.top`, `.hint`, about lines 17–31); `#nightHud` markup and CSS; the ledger
  markup `<aside id="ledger"` and all `#ledger …` CSS; `Mun.render`, `Orders.render`, `Kitchen.render`,
  `Def.render`, `Upg.render`, `Away.show`; `saveW`/`loadW`; the button `#bLedger`.

## Files you may change
`dao-coi-nuoc.html` only: the HUD and ledger markup, CSS rules for `#hud`, `.hintWrap`,
`#nightHud`, `#ledger …` (new or existing), `Orders.render` (row markup only), `Mun.render`
(one call for the badge), `Away.show`, `saveW`/`loadW` (one flag), and a **new** `const LedgerUI={...}`
placed right after `const Kitchen={...}`; the boot line (`LedgerUI.build();` after `Kitchen.build();`).
No game rules change.

## Spec
1. **Tabs.** Under the ledger title add a tab bar (`role="tablist"`, buttons `role="tab"`,
   `aria-selected`) with four tabs; each wraps existing sections in a `<div role="tabpanel">`:
   - **Nhà** — Kho chung, Việc hôm nay, Nhờ Linh (and their notes).
   - **Buôn bán** — Đơn hạc giấy, Bếp và chạn.
   - **Nâng cấp** — Nâng cấp.
   - **Phòng thủ** — Phòng thủ.
   `#lAway` (the away summary) and the first-run guide stay ABOVE the tabs. Default tab: Nhà.
   Remember the last tab in `localStorage['dao-ledger-tab']` (wrap in try/catch). Keep the
   existing render functions working (they write into the same element ids). Tabs styled like the
   existing `.seg` buttons; the selected one uses the same pressed style as `aria-pressed=true`.
2. **Badge.** When at least one order can be sent now (`Orders.can(o)===''`), or the kitchen queue
   just finished a dish, show a small dot on `#bLedger` (a `::after` on a class, colour
   `var(--glass-on)`) and on the "Buôn bán" tab. `LedgerUI.badge()` is cheap (called from
   `Mun.render` and once a second from a single `setInterval` created in `build`). Remove the dot
   on the tab when that tab is opened.
3. **Night HUD placement.** Move `#nightHud` into `.hintWrap`, right after `#fps`, as a normal block
   (no absolute positioning), so it sits under the hint lines and never overlaps them. Keep it
   visible on narrow screens (it is not `.hint`).
4. **Order rows.** Layout each order as: sender (bold) on line 1; needs on line 2; pay on the left
   and the two buttons on the right of line 3 (`Gửi hàng`, `×`), never wrapping the × alone.
5. **First-run guide.** If `W.guide` is not set (new flag, saved, default 0), show above the tabs a
   card "Cách chơi" with these lines and a button "Đã hiểu" that sets `W.guide=1` and saves:
   - "Linh tự sống trên đảo. Bạn là Mun: giữ sổ, nhờ việc và lo cho cô."
   - "Nhờ Linh chặt củi, câu cá, nhặt trứng… rồi gửi hàng theo đơn hạc giấy để lấy xu."
   - "Dùng xu mua nâng cấp; nấu món ở bếp để bán giá cao hoặc ăn trước đêm."
   - "Đêm xuống ma sương leo lên mép đảo. Dựng tháp, nâng vòm ở mục Phòng thủ. Thua cũng không mất gì."
   - "Tắt trang cũng được: đảo vẫn chạy tối đa một ngày, Mun sẽ kể lại."
   Open the ledger on first run so the guide is seen.

## Constraints
- No 3D, no new per-frame work beyond the existing renders. All text Vietnamese.
- Keyboard: tabs reachable with Tab and switchable with Enter/Space; focus outline unchanged.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block.
