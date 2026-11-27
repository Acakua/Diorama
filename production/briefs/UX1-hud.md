# UX1 — HUD: a status card, a calmer toolbar, a settings menu and a help popover

## Objective
Redesign the always-visible HUD so the main screen answers "what time is it, what do I have, what
is waiting" at a glance, and so the one important button (Sổ của Mun) stands out from camera and
settings buttons. Design spec: `design/ux/redesign-v2.md` — read §3 "Phân cấp", §4 "Wireframe",
§5 "Màu, chữ, hình dạng" and §6 "Thành phần" (bullets "Thẻ trạng thái", "Cụm ⚙", "?") by heading.
Art rules: `design/art-bible.md` §7 "Giao diện".

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: the `<style>` block top (`:root`, `#hud`, `.top`, `.hintWrap`, `.hint`,
  `.tools`, `button`, `button[aria-pressed="true"]`, the `@media (max-width:560px)` rule); the HUD
  markup `<div id="hud">` … `</div>` (about lines 113–140); every `$('bX').onclick` for the toolbar
  buttons (`bModel`, `bHat`, `bAnchor`, `bCine`, `bFollow`, `bLedger`, `bJournal`, `bRoof`, `bWx`,
  `bSound`, `bPerf`; about lines 2904–2955, 3079, 3212); the HUD update in `frame` (search
  `// HUD`: `$('fps')`, `hudT`, `dayLbl`); `updStore`, `woodMax`, `W.coins`, `W.def.cry`,
  `W.orders`, `Orders.can`, `hour`, `Def.nightAt`; the `H` key handler.

## Files you may change
`dao-coi-nuoc.html` only: the `<head>` (add `<meta name="viewport" content="width=device-width, initial-scale=1">`
after the charset), CSS (new rules and edits to the rules listed above), the HUD `.top` markup, the
HUD block in `frame` (one call `Status.tick()` inside the `hudT` branch; the fps text line), and a
**new** `const Status={...}` placed right before `const LedgerUI={`. Keep every existing element id
and every existing `onclick` handler working unchanged (move elements, do not rename them).
No game rules change. Do not touch the ledger internals (UX2) or `note()` (UX3).

## Spec
1. **Pressed-toggle style.** Change `button[aria-pressed="true"]` to the "ấn chìm" style: background
   `#f4efe21f`, border `var(--ink-dim)`, colour `var(--ink)`, and an inset 2 px amber bar at the
   bottom (`box-shadow: inset 0 -2px 0 var(--glass-on)`). Add a class `.cta` with the old amber fill
   (`background:var(--glass-on);color:var(--on-ink);border-color:var(--glass-on)`) for buttons that are
   the action to take now; give `.cta` to `#lGuideOk` and `#lAwayOk` only in this task.
2. **Status card** (top-left, replaces the hint lines there). New markup inside `.hintWrap`, before
   `#modelMsg`: `<section id="status" aria-label="Trạng thái đảo">` with
   - `#stDay`: day line — move the existing `#dayLbl` text here (keep `#dayLbl` element id; it may
     move into the card; the clock stays bottom-left). 12px, `--ink-dim`.
   - `#stRes`: a row of chips. Each chip: a small inline SVG icon (18 px, stroke 1.6, `currentColor`,
     one consistent line style) + a number in Literata 16 px `tabular-nums` + a visually hidden label
     for screen readers. Chips: xu (coin), tinh thể (crystal/diamond), củi `6/30` (log), bí
     (pumpkin), cá (fish), trứng (egg), thuốc (bottle). Each chip has `title` with the Vietnamese name.
     Xu and tinh thể chips first and slightly larger; goods chips grouped after a thin divider.
   - `#stNext`: one line "Sắp tới: …" 12px dim, built from: number of orders you can send now
     (`Orders.can(o)===''` → "2 đơn gửi được"), else open orders ("1 đơn đang chờ"), and the time to
     night ("đêm sau 3 giờ 20 phút" from `hour` to 21:00, or "đang đêm" while `Def.on`, or "đêm yên"
     when `W.def.calm`). Join with " · ".
   - Card style: background `#14201fb3`, border `1px solid var(--ink-faint)`, radius 3px, padding
     8px 10px, `backdrop-filter: blur(8px)`, `pointer-events:auto`, width fit-content, max-width 520px.
   - `Status.tick()` updates text only when values change (keep a signature string); called from the
     existing 0.2 s `hudT` branch. When xu or tinh thể rises, show a small "+n" (amber for xu, violet
     `#b79bff` for tinh thể) that floats up 10 px and fades over 0.8 s (CSS animation on a span that
     is reused, not created per frame).
   - The `#nightHud` element stays in `.hintWrap` for now (UX3 moves it).
3. **Hints and fps.** Remove the long `.hint` controls line from the top-left; its text moves into
   the help popover (item 5). `#fps` stays in the DOM but is hidden unless the perf panel `#perf` is
   open (toggle a class on `body` or check `#perf` hidden state when writing it).
4. **Toolbar** (top-right `.tools`), two rows, right-aligned:
   - Row 1 (primary): `#bLedger` with a small book icon + text "Sổ của Mun", 14px, padding 10px 14px,
     slightly brighter glass `#14201fd9`; then `#bJournal` "Nhật ký" normal size. The badge dot stays.
   - Row 2 (secondary, icon-only square buttons 34×34, each with `aria-label` and `title` holding the
     old Vietnamese text): `#bAnchor` (anchor), `#bCine` (film), `#bFollow` (footsteps), then a gap,
     then a new `#bHelp` "?" and a new `#bMenu` (gear icon, `aria-haspopup="menu"`, `aria-expanded`).
   - **Settings menu** `#menu` (`role="menu"`, hidden by default, anchored under `#bMenu`, glass card
     `#14201fe6`, min-width 220px): menu items are the existing buttons moved inside it, full width,
     left-aligned text: `#bWx` "Mùa và thời tiết", `#bSound` "Âm thanh", `#bPerf` "Hiệu năng",
     `#bRoof` "Mở mái nhà", `#bHat` "Mũ phù thủy" (keep its `hidden` logic), `#bModel` "Nạp mô hình
     VRoid khác". Give them `role="menuitem"` (toggles: `menuitemcheckbox` with `aria-checked`
     mirrored from `aria-pressed`). Opening a panel from the menu closes the menu. Esc and a click
     outside close the menu; focus returns to `#bMenu`.
5. **Help popover** `#help` (hidden, anchored under `#bHelp`, same card style, max-width 300px):
   title "Điều khiển", the control lines as a short list (Kéo để xoay; Cuộn hoặc chụm tay để zoom;
   Nhấp đúp để đến gần một chỗ; Bấm vào chỗ làm việc để nhờ Linh; Tắt Góc neo để xoay tự do; Phím H
   ẩn chữ), and a button "Xem lại cách chơi" that opens the ledger and shows `#lGuide` (unhide it;
   do not reset `W.guide`). Esc / outside click closes it.
6. **Narrow screens.** With the viewport meta, under 700 px: the status card shows only xu, tinh
   thể and the `#stNext` line (goods chips hidden); row 1 buttons keep text; row 2 stays icons.
   Remove the old `@media (max-width:560px){.hint{display:none}…}` rule only if it no longer applies.

## Constraints
- Icons: inline SVG in the markup, `aria-hidden="true"`, no external files, no emoji.
- No new per-frame work beyond `Status.tick()` in the 0.2 s branch; no allocation in it except when
  a value changes.
- Text Vietnamese. Minimum font size 12px for anything you add. Keyboard: every new control is a
  `<button>`, reachable by Tab, focus outline unchanged.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block. The orchestrator screenshots 1600×900, 1280×720 and 375×812.
