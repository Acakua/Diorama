# UX3 — Feedback: toasts, a night banner, a dawn card, a viewing mode, a phone sheet

## Objective
Game events (a new order, a dish done, a goal met, a purchase) currently replace Linh's narration
line at the bottom for a few seconds, so the island loses its storyteller voice; night and dawn are
a small text block in the top-left. Give events their own quiet channel, make the night visible,
move the day scrubber (which lets the player skip a whole night) into a "viewing mode", and make the
ledger usable on a phone. Spec: `design/ux/redesign-v2.md` §4 "Wireframe" and §6 "Thành phần"
(bullets "Toast", "Băng đêm", "Cụm ⚙") — read by heading. UX1 and UX2 are merged.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: `function note(` and where `AG.note` / `AG.noteT` are read in `frame`
  (search `AG.noteT>0&&AG.note`); every `note(` call site (grep); `#nightHud` markup and CSS;
  `Def.hud`, `Def.resolve`, `Def.last`; the bottom HUD `.bottom`, `.bar`, `#scrub`, `.ticks`,
  `scrubbing`; the settings menu `#menu` from UX1; `#ledger` CSS from UX2.

## Files you may change
`dao-coi-nuoc.html` only: `note` (its body), the `frame` line that chooses between `AG.note` and the
narration, CSS, the HUD markup (`#toasts` container, `#nightHud` move), `Def.hud` (markup/classes
only), `Def.resolve` (one call that shows the dawn card), the settings menu markup (one new item),
the `.bar` markup, and a **new** `const Toast={...}` placed right before `const LedgerUI={`.

## Spec
1. **Toasts.** `<div id="toasts" aria-live="polite">` at the top centre of `#hud` (below the top
   edge 16px, centred, width min(420px, 100vw-32px), column, gap 6px). `Toast.show(text, kind='info',
   sec=4)`: a glass card `#14201fe6`, 13px Be Vietnam Pro, padding 8px 12px, radius 3px, a 3px left
   border by kind: `gold` (`--glass-on`: coins, gifts, sales), `violet` (`#b79bff`: night, crystals),
   `info` (`--ink-faint`). Max 3 visible (oldest leaves first), fade/slide 0.25s, reuse 3 nodes.
   `note(t,sec,log)` now calls `Toast.show(t, kind, sec)` (pick `kind` from simple keywords: "xu" or
   "quà" → gold; "đêm", "vòm", "ma sương", "tinh thể" → violet; else info) and **no longer sets
   `AG.note`**, so the bottom line always shows Linh's narration. Keep its journal logging exactly.
2. **Night banner.** Move `#nightHud` from `.hintWrap` to the top centre above `#toasts` (same
   container, first child). Style: glass card 260px, "Đêm 12 · Sóng 3/6" Literata 15px, ward bar
   6px full width (amber fill → shifts toward `#e07a5f` below 35 %), "Tan 14 · +14 tinh thể" 12px.
   Shown only while `Def.on` (existing logic).
3. **Dawn card.** In `Def.resolve` (live nights only, not `simNight`), call
   `Toast.show('Bình minh: vòm giữ vững · '+kills+' ma sương tan · +'+cry+' tinh thể','violet',8)`
   or, when lost, `'Bình minh: vòm vỡ, kho vẫn nguyên · '+kills+' ma sương tan'`. Use the values the
   function already has.
4. **Viewing mode.** Hide the scrubber block `.day` by default. Add to `#menu` a toggle
   `#bView` "Chế độ ngắm" (`role="menuitemcheckbox"`, `aria-checked`); when on, `.day` shows and a
   small label "Chế độ ngắm · kéo để xem giờ khác" sits above it; remembered in
   `localStorage['dao-view']` (try/catch). Speed buttons stay always visible.
5. **Phone sheet.** Under 700 px width: `#ledger` (and `#journal`) become a bottom sheet: left 0,
   right 0, bottom 0, top auto, height 70vh, radius 3px 3px 0 0, with a 36×4 px handle bar at its
   top; the clock line stays visible above it when there is room. Toasts sit under the toolbar.

## Constraints
- No game rule change. No per-frame allocation (toasts reuse nodes). Respect
  `prefers-reduced-motion` (no slide, only fade). Text Vietnamese, minimum 12px.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block, listing every `note(` call site you checked.
