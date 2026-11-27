# G5a — Night defence: rules, simulation, ledger and HUD (no 3D yet)

## Objective
The player chose an AFK fight: **"Giữ đảo ban đêm"** (`design/game-brief.md`, "Phạm vi v2").
Each night mist wraiths climb the island's rim in waves and press on the rune ward; magic towers
and Linh's night charm shoot them automatically. The player only **prepares** (buys towers,
levels them and the ward, picks Linh's charm). This task builds the **whole rule set as data**:
the per-frame simulation, the dawn reward, a headless `simNight()` for away time, the ledger
section and a small night HUD. A later task (G5b) draws it in 3D from the state you expose.
No fail state: if the ward breaks, the wraiths drift off and only that night's dawn bonus is lost.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`:
  - `const R=13;` and `const HOUSE={...}` (about lines 222–228): island radius and house.
  - `function frame(` (about line 2840): `hour` advances by `dt*speed*24/DAY_S`; `Mun.step(sdt);`
    (about line 2855) is where per-frame logic runs. `DAY_S=960` real seconds per island day at 1×.
  - `const W`, `saveW`, `loadW`, `newDay`; `const Orders`, `const Upg` (`has`, buy/can/render
    pattern), `const Away` (G3: away time, `Away.sum`, the "Trong lúc bạn vắng…" block).
  - `Place.ward` (about line 507): the existing rune-ward band at the rim (visual only; G5b uses it).
  - `logJ`, `note`, the ledger markup `<aside id="ledger"`, `#ledger` CSS, `window.__dao={`.

## Files you may change
`dao-coi-nuoc.html` only: `const W` (add `def`), `saveW`, `loadW`, a **new** `const Def={...}`
placed right after `const Away={...}`, `frame` (one call line after `Mun.step(sdt);`), `Away`
(call `Def.simNight` for nights crossed while away, add lines to its summary), the ledger markup
(one new section), the HUD markup (one new element inside `<div id="hud">`), new CSS rules
(`#ledger …`, `#nightHud …`), the boot line (`Def.build();` after `Upg.build();`), `Mun.render`
(call `Def.render(force)` next to the others) and `window.__dao` (`get def(){return Def},`).

## Spec

### State (`W.def`, saved and validated like the rest)
`{tw:[1,0,0], ward:1, charm:'bolt', charms:['bolt'], cry:0, core:0, nights:0, calm:0}`
- `tw[i]`: level of tower slot i (0 = not built). Slot 0 starts built at level 1.
- `ward`: ward level (1–10). `cry`: crystals. `core`: mist cores (rare). `nights`: nights held.
- `calm`: 1 = "Đêm yên" (no fight).

### Geometry (island units, island-local XZ; the island centre is 0,0)
- Tower slots at radius 8.5, angles 0.6, 2.7, 4.8 rad: `TW_POS[i]=[8.5*cos a, 8.5*sin a]`.
- Linh's charm fires from `HOUSE.tower` ( `[2.2,-1.45]` XZ ).
- A wraith has `{a, p, hp, max, slow, id}`: azimuth `a` (rad) and progress `p` 0→1 climbing the
  rim from below; at `p>=1` it is **at the ward** (radius R+0.4) and deals damage. Its XZ position is
  `(R+0.4)*(cos a, sin a)`; `y = -4 + 4.6*min(p,1)` (G5b uses this; just expose it).

### Night timing
- Night = island hours 21:00 → 04:30. `Def.on` true inside it unless `calm`.
- 6 waves, wave k (0–5) starts at `21.5 + k*1.15` h. Wave size `n = 3 + k + floor(L*0.7)`,
  where `L = W.def.nights`. Wraith hp `18*(1+0.12*L)`. Spawn spread over 8 night-seconds, random
  azimuth. Climb speed: `p += dt/14` (×0.5 while slowed).
- "Night-seconds": call `Def.step(dt*speed)` from `frame` when `speed>0&&!scrubbing`; inside,
  sub-step at most 0.1 s and at most 3 s per frame (drop the rest). At 1× a night lasts ~300 s.
- At dawn (hour leaves the window, also after `setHour`/scrub jumps) resolve the night once.

### Combat (per night-second)
- Tower level t: fires every `1.0 s` at the wraith with the **highest p** within 11 m (XZ distance
  from the tower to the wraith); damage `5 + 4*(t-1)`.
- Charms (one active, `W.def.charm`):
  - `bolt` "Cầu lửa": every 3 s, 22 dmg to the highest-p wraith (any range).
  - `star` "Mưa sao": every 6 s, 12 dmg to every wraith within 4 m (along the rim) of the highest-p one.
  - `frost` "Sương giá": every 5 s, 6 dmg and `slow=3` s to every wraith with p>0.5.
- Ward hp `max = 100 + 35*(ward-1)`; every wraith at p≥1 deals `2.5` hp/s. Ward at 0 → the night
  is **lost**: all wraiths fade, no more waves, `note('Vòm cổ ngữ vỡ, ma sương tràn qua mép đảo rồi tan khi trời sáng. Kho vẫn nguyên.')`.
- Potions: once per night when ward hp < 35 % and `W.potions>=1`, use one: +40 % of max hp,
  `note('Linh ném một chai thuốc vào vòm, vòm sáng rực trở lại.')`.
- Kill: `cry += 1`. Record events in a ring buffer `Def.fx` (`{type:'shot'|'charm'|'hit'|'kill', from:[x,z], to:[x,z], t}`, 64 entries, overwrite oldest) so G5b can draw beams without logic changes.

### Dawn resolve
- Held (ward > 0 after the last wave cleared or at 04:30): `nights += 1`, bonus `cry += 5 + 2*min(nights,20)`;
  15 % chance `core += 1`. `logJ('Đêm '+nights+': vòm cổ ngữ giữ vững, Mun nhặt được X tinh thể.')`.
- Lost: no `nights` increase, no bonus; kills still counted. `logJ` a gentle line.
- Store `Def.last={held, kills, cry, core}` for the ledger.

### Away (headless)
`Def.simNight()` runs the same rules with dt 0.25 and no FX, returns `{held,kills,cry,core,pot}`,
and applies them to `W.def`/`W.potions`. `Away` calls it once per night window fully crossed while
away (at most 1, since away time is capped at 24 h) and adds a summary line, e.g.
"Đêm qua vòm giữ vững: 23 ma sương tan, +51 tinh thể."

### Shop (ledger section "Phòng thủ", after "Nâng cấp")
Show: crystals, cores, nights held, ward level, a row per tower slot, the charm choice, and a
toggle "Đêm yên". Costs:
- Build slot 1: 60 xu + 10 tinh thể. Build slot 2: 120 xu + 25 tinh thể.
- Tower level t→t+1 (max 8): `12*t` tinh thể. Ward level w→w+1 (max 10): `15*w` tinh thể.
- Unlock `star`: 30 tinh thể; unlock `frost`: 30 tinh thể + 1 lõi sương. Switching is free.
Same `can()/buy()` pattern as `Upg` (Vietnamese reasons; buttons disabled with `title`). Buying
during a night is allowed and takes effect at once.

### Night HUD
A small element `<div id="nightHud" hidden>` in `#hud`, top-left under the status text, shown
only while `Def.on`: "Đêm 12 · Sóng 4/6", a ward bar (`<i>` width = hp %), and "Tan: 14 · +14 tinh thể".
Update its text at most 4 times a second.

### Debug API
`__dao.def` exposes `Def` with: `state` (wraith array), `fx`, `on`, `ward` ({hp,max}), `wave`,
`simNight()`, `startNight()` (jump `hour` to 21.45 and begin), and `cost(...)`.

## Constraints
- **No meshes, materials or textures** in this task. G5b draws from `Def.state` and `Def.fx`.
- No allocations per frame in `Def.step` beyond pushing new wraiths at spawn (reuse objects from a
  pool of 64). Keep the sim cheap: at most 40 live wraiths (excess spawns wait).
- Saves from before this task load with the default `W.def`.
- Exact string replacement only.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.
- Report a headless check you ran in node or describe precisely: `simNight()` for `nights=0`,
  default state → expected held; for `nights=30`, default state → expected lost.

## Return
The AGENTS.md report block, with the simNight results you measured (kills, held) for L=0, 10, 30.
