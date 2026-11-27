# UX2 — Mun's ledger: wider, five tabs, short text, visible reasons, defence cards

## Objective
Mun's ledger (`#ledger`) is where the whole game is played, but it is a narrow 320–352 px column
that covers the toolbar at 1280 px, one tab scrolls 1000 px, long explanations sit everywhere, and a
locked button only explains itself in a hover tooltip. Rework the ledger per
`design/ux/redesign-v2.md` §4 "Wireframe", §5 "Màu, chữ, hình dạng" and §6 "Thành phần" (bullet
"Sổ, 5 tab") — read by heading. UX1 (already merged) added `.cta` (amber "do this now" button) and
made pressed toggles a calm "ấn chìm" style; the status card in the HUD now shows the stores.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: all `#ledger …` CSS and the shared panel rule
  `#journal,#perf,#wxp,#ledger{position:fixed;…}`; `.cta`; the ledger markup `<aside id="ledger"`
  … `</aside>`; `const LedgerUI` (tabs, `open`, `badge`, `build`); `Mun.render` (writes `#lStore`,
  `#lTasks`, `#lAdd`); `Orders.render`; `Kitchen.render`; `Upg.render`; `Def.render`, `Def.label`,
  `Def.why`, `Def.cost`; `Market.render`; `Goals.render`; the HUD toolbar `.tools` (to know its
  height).

## Files you may change
`dao-coi-nuoc.html` only: `#ledger` CSS (you may split `#ledger` out of the shared panel rule),
the ledger markup, `LedgerUI` (tab list and keys), and the **render** functions listed above —
markup and classes only, no rule, cost or state change.

## Spec
1. **Place and size.** `#ledger` width `clamp(380px, 28vw, 440px)` (and `calc(100vw - 32px)` max);
   `top` just below the toolbar's two rows (measure: the toolbar is two rows now; use a CSS variable
   `--toolbar-h` set once in `LedgerUI.build()` from `.tools` `getBoundingClientRect().bottom`
   and on `resize`); `bottom: 16px`; inner scroll. It must never cover any toolbar button.
2. **Five tabs** (same tablist markup and keyboard behaviour as now), keys and order:
   `today` "Hôm nay" (Mục tiêu đảo, Việc hôm nay, Nhờ Linh) · `trade` "Buôn bán" (Đơn hạc giấy,
   Thuyền chợ) · `kitchen` "Bếp" (chạn, hàng nấu, nút nấu, bữa tối trước đêm) · `upg` "Nâng cấp" ·
   `def` "Phòng thủ". Map an old saved `localStorage['dao-ledger-tab']` value `home` → `today`.
   The badge rules stay: trade dot on "Buôn bán" (orders) **and** on "Bếp" when a dish finished
   (split the two), goals dot on "Hôm nay".
3. **Kho chung leaves the ledger** (it lives in the HUD now). Keep a hidden `#lStore` element (or
   guard `Mun.render`) so nothing breaks.
4. **Short text.** Every explanatory `p.pNote` paragraph longer than one line moves into a closed
   `<details class="how"><summary>Cách tính</summary>…</details>` at the end of its section (summary
   12px dim, underline on hover). One-line notes (e.g. "Hôm nay thuyền còn nhận 14 món.") stay.
5. **Visible reasons.** Wherever a render function disables a button and puts the reason in
   `title`, also render the reason as `<span class="why">` right after the button (12px,
   `--ink-dim`, italic). Keep the `title`.
6. **Amber means act.** Add `.cta` to buttons that are enabled AND are the thing to do: "Gửi hàng",
   "Nhận quà", "Mua · … xu" (upgrades and market crystal pouch), "Nâng · …" / "Dựng · …" in defence,
   "Nấu · …". Disabled ones never get `.cta`. Selected tab keeps the amber style (selected tab ≠
   pressed toggle: give `.lTab[aria-selected="true"]` the amber fill explicitly).
7. **Defence as cards.** In `Def.render`: a top line "Tinh thể 227 · Lõi sương 0 · Đêm đã giữ 12"
   (numbers in Literata). Then cards (border `--ink-faint`, radius 3px, padding 8px 10px, gap 6px):
   "Vòm cổ ngữ" and "Tháp 1/2/3", each with its level as pips (filled `●` amber for owned levels,
   `○` dim for the rest, up to its max) plus "cấp 3/10", and its action button + `.why`. Charms as a
   `.seg` of three buttons (selected = `aria-pressed`) with the unlock buttons under it. "Đêm yên"
   as a toggle with a one-line description. Keep `Def.render`'s signature-based redraw.
8. **Rows.** Orders, market and upgrade rows share one row style: name (Literata 14px) on line 1,
   details 12px dim on line 2, actions right-aligned; 8px vertical padding, divider `--ink-faint`.

## Constraints
- No game rule, price or state change. Old saves and the `dao-ledger-tab` key keep working.
- No new per-frame work. Text Vietnamese, minimum 12px.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block.
