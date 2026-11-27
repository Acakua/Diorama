# G1 — Paper-crane orders: sell from the shared stores for coins

## Objective
Coins (`W.coins`) are shown in Mun's ledger but nothing earns them yet. Add **orders that arrive by
paper crane**: each morning 1–2 orders appear in the ledger, each asking for some of the stores
(eggs, fish, pumpkins, potions, firewood) and paying coins. The player clicks **"Gửi hàng"** to send
an order (stores go down, coins go up) or **"×"** to set it aside. No penalty, no deadline pressure.
Read `design/game-brief.md` ("Core loop", "Phạm vi v2") for the spirit: cosy, no fail state.

## Read first
- `AGENTS.md` (rules, report block).
- `dao-coi-nuoc.html`:
  - `const W={day:1,...}` (about line 2006): the world state. Stores: `W.wood` (firewood, cap 18),
    `W.stock` (pumpkins), `W.fish`, `W.eggs`, `W.potions`, `W.coins`. Values may be fractional; the
    ledger shows `Math.floor`.
  - `function saveW(` and `function loadW(` (about lines 2019–2032): the save, and its validation
    (every loaded value is clamped; a bad save must never stop the page).
  - `function newDay(` (about line 2033): runs at island midnight.
  - `const Mun={` … `render(force){` (about lines 2036–2105): the ledger object. `render` rebuilds
    `#lStore` and `#lTasks` only when its signature string `sig` changed.
  - The ledger markup `<aside id="ledger"` (about line 105) and its CSS rules that start with
    `#ledger` (about lines 45–58).
  - `logJ(t)` writes a journal line in Linh's/Mun's voice; `note(t,sec)` shows a short caption.
  - `window.__dao={` (about line 2469): the debug API.

## Files you may change
`dao-coi-nuoc.html` only, and inside it only:
- the ledger markup (`<aside id="ledger"`): add one section;
- CSS: add new rules starting with `#ledger` (do not edit existing rules);
- `const W={...}`: add `orders:[]`;
- `saveW`, `loadW`, `newDay`;
- a **new** `const Orders={...}` object placed right after the closing `};` of `const Mun={...}`
  (i.e. just before `const Life={};`);
- `Mun.render`: call `Orders.render(force)` at its start (before its early return) so the
  orders list is redrawn with the ledger;
- the boot line containing `Mun.build();` : add `Orders.build();` after it;
- `window.__dao={`: add `get orders(){return Orders},`.

## Spec
- **Templates** (`ORDER_T`, 8 entries): `{from:'<sender>', need:{<store>:n,...}, pay:<coins>}`.
  Senders are Vietnamese names of neighbour islands/people, e.g. `'Bà Sáu đảo Mây Thấp'`,
  `'Tiệm trà đảo Gió'`, `'Ông lái đò Mù Sương'`, `'Thư viện đảo Đá'`, `'Cô thợ rèn đảo Lửa'`,
  `'Lũ trẻ đảo Bèo'`, `'Bếp nhà Thanh Lam'`, `'Hội phù thủy tập sự'`. Store keys: `eggs, fish,
  stock, potions, wood`. Price guide per unit: wood 2, egg 4, fish 6, pumpkin 10, potion 15; each
  template pays that sum **+20 %**, rounded. Keep each order small (2–6 units total, 1–2 kinds)
  so the stores a normal island day makes can fill it.
- **Order object**: `{id, t:<template index>, need:{...}, pay, d:<day posted>}`. `id` is a
  running integer stored in `W.orderN`.
- **Arrival**: `Orders.newDay()` is called from `newDay()` (after `Mun.newDay()`): drop orders
  older than 2 days (`W.day - o.d >= 2`), then while fewer than 2 open orders roll: 1 new order with
  probability 1, a 2nd with probability 0.5; never two of the same template open at once. When an
  order arrives write `logJ('Một con hạc giấy đậu xuống bậu cửa: '+from+' đặt hàng.')` and
  `note('Có đơn hàng mới bằng hạc giấy. Mở Sổ của Mun để xem.',5)`. On a fresh save (no orders and
  `W.orderN` 0) seed one order at boot from `Orders.build()`.
- **Send**: `Orders.can(o)` returns `''` when every `Math.floor(W[k]) >= n`, otherwise a Vietnamese
  reason (`'Còn thiếu 2 quả trứng.'`). `Orders.send(i)`: if `can` is `''`, subtract each need,
  `W.coins += pay`, remove the order, `updStore()` if it exists, `logJ('Linh buộc gói hàng vào
  chân hạc giấy gửi '+from+'. Mun ghi thêm '+pay+' xu.')`, `saveW()`.
- **Set aside**: `Orders.drop(i)` removes it, `saveW()`.
- **Ledger UI**: a new section between "Kho chung" and "Việc hôm nay":
  `<h3>Đơn hạc giấy</h3><ul id="lOrders"></ul>`. Each `li`: sender (bold), the needs as
  `have/need unit` (Vietnamese units: khúc củi, quả bí, con cá, quả trứng, chai thuốc), the pay
  (`+40 xu`), a button `Gửi hàng` (disabled with `title` = reason when `can` is not `''`) and a
  `×` button (`aria-label='Bỏ đơn của '+from`). Empty list: `li.empty` "Chưa có đơn nào. Hạc giấy
  thường tới vào buổi sáng." Style like `#lTasks` (reuse its look; add new `#ledger #lOrders` rules
  only).
- `Orders.render(force)` uses its own signature string (orders + floored stores) so it does not
  rebuild DOM every frame.
- **Save/load**: `saveW` adds `orders:W.orders.map(o=>({id:o.id,t:o.t,need:o.need,pay:o.pay,d:o.d})),orderN:W.orderN||0`.
  `loadW` keeps at most 2 orders whose `t` is a valid template index, whose `need` keys are store
  keys with integer values 1–20, `pay` an integer 1–1000, `d` an integer; anything else dropped.

## Constraints
- Do not change how stores are produced or consumed elsewhere, nor the tasks logic.
- No new 3D objects, materials or textures in this task (a crane flight may come later).
- No `new` per frame; nothing in the render loop besides what `Mun.render` already triggers.
- Edit by exact string replacement only; do not reformat lines you do not change.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block. Under RISKS: anything that could make a send double-count, or a
loaded save carry a broken order.
