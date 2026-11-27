# G5b — Night defence in 3D: mist wraiths, magic towers, beams

## Objective
G5a built the night-defence rules as data (`const Def`, see `__dao.def`). Nothing is drawn yet.
Draw it **on the island**, cheaply, from `Def`'s state only (no rule changes): mist wraiths
climbing the rim, the magic towers in their slots, the beams and charms they fire, a puff when a
wraith fades, and the existing rune ward glowing brighter as it takes hits. It must read as a cosy
fairy-tale skirmish, not horror (`design/art-bible.md` §1 "Không khí chung", §6 "Phép thuật" and
"Vòm bảo vệ"; avoid the sci-fi hex-shield look the bible forbids).

## Read first
- `AGENTS.md`; `design/art-bible.md` sections 1, 2 ("Bảng màu"), 6 and 9 ("Ngân sách hiệu năng")
  — read by heading, not whole.
- `dao-coi-nuoc.html`:
  - `const Def={` (G5a): `Def.state` (live wraiths `{a,p,hp,max,slow,id}`), `Def.fx` (ring buffer
    of `{type,from:[x,z],to:[x,z],t}`), `Def.on`, `Def.ward` (`{hp,max}`), `TW_POS`, `W.def.tw`,
    `W.def.charm`. Wraith island-local position: XZ `(R+0.4)*(cos a, sin a)`,
    `y = -4 + 4.6*min(p,1)`.
  - `Place.ward` (search `Place.ward={d,m,t:-1}`, about line 507) and the line that drives it
    (search `const Wd=Place.ward`, about line 531): uniforms `uW`, `uA`.
  - `function burst(` (a puff of `Magic` particles) and `Magic.C` (named colours: violet, aqua, gold, ember…).
  - `foldRigid` / `freezeStatic` (about lines 2675–2720): **why every new object here must be an
    `InstancedMesh` or `LineSegments` whose own transform never changes**, and must be referenced
    from `Place` so it counts as "held".
  - The warm-up comment near the end ("compile every program before the first frame, hidden ones
    too"): everything must exist at boot.
  - `hAt(x,z)`: ground height (island-local) for placing towers.

## Files you may change
`dao-coi-nuoc.html` only: a **new** function `buildDefence()` placed right after `const Def={...}`,
a **new** `Def.draw(dt)` method (add it to the `Def` object; it must only read state), the boot
line (call `buildDefence();` right after `buildPlaces();`), `frame` (one call `Def.draw(dt);`
right after the `Def.step(...)` line), and the `const Wd=Place.ward` line (only to also raise
the ward while `Def.on`, see Spec).

## Spec (all objects created in `buildDefence`, added to `island`, stored in `Place.def`)
- **Wraiths** — `InstancedMesh` capacity 40, `count` = live wraiths each frame:
  - Body: a soft teardrop (`LatheGeometry` of ~10 profile points, 12 segments, about 0.55 m tall,
    0.28 m wide, rounded bottom, wispy point at top). Material: `MeshStandardMaterial` colour
    `#c9d6f0`, emissive `#7f8fd8` intensity 0.9, `transparent:true, opacity:.62, depthWrite:false`,
    `roughness:1`. Cast no shadow.
  - Eyes: a second `InstancedMesh` (capacity 80, two per wraith) of tiny spheres (r 0.035),
    `MeshBasicMaterial` `#ffe7a8`. Eyes sit on the side facing the island centre.
  - Motion: position from the formula above, a gentle sway `sin(time*2+id)` of 0.06 m, a bob of
    0.05 m, slight lean toward the island; scale grows from 0.3 to 1 over the first 10 % of p and
    shrinks to 0 over 0.35 s when killed (keep a short fade list in `Place.def`).
- **Towers** — slot i at `TW_POS[i]`, ground `hAt`:
  - Pillar: `InstancedMesh` (capacity 3) of a tapered stone `CylinderGeometry(.22,.32,1.6,8)` in
    `#8a8174` (like the yard stones), cast shadow. Unbuilt slot: scale 0.
  - Crystal: `InstancedMesh` (capacity 3) of `OctahedronGeometry(.22)`, `MeshStandardMaterial`
    `#b79bff`, emissive `#a880ff`, emissiveIntensity `0.6 + 0.25*level` (use instance colour to
    vary brightness per level), floating 0.35 m above the pillar, slowly turning and bobbing.
    At night (`Def.on`) a little brighter; by day calm.
- **Beams** — one `LineSegments` with 64 segments, `BufferGeometry` positions using
  `DynamicDrawUsage`, `LineBasicMaterial({vertexColors:true, transparent:true, blending:THREE.AdditiveBlending, depthWrite:false})`.
  Each frame draw every `Def.fx` entry younger than 0.25 s as a segment from its `from` (at tower
  crystal height, or `HOUSE.tower` top ≈ 4.5 m for charms) to its `to` (wraith position). Colours:
  tower shot `#c7a8ff`, `bolt` `#ffb35c`, `star` `#ffe08a`, `frost` `#a8f0ff`; fade by age.
  Unused segments collapse to zero length. `setDrawRange` to the used count.
- **Kill puff**: when an `fx` entry of type `kill` is new, call `burst(worldPos, Magic.C.violet, 18, .7)`.
  `star`: also a gold `burst(...,10,.5)` at the target. Never more than 6 bursts per frame.
- **Ward**: while `Def.on`, keep `Place.ward` visible and its `uA` at least
  `0.35 + 0.5*(1-hp/max)` (brighter when hurt), with a short flash (+0.3, 0.2 s) on each `hit`
  event. Outside the night, leave the existing bedtime logic exactly as it is.
- **Performance**: ≤ 6 new draw calls, ≤ 40 wraiths, no per-frame allocation (reuse one
  `Object3D`/`Matrix4`/`Vector3` set), nothing new in the shadow pass except the 3 pillars.

## Constraints
- Do not change `Def.step`, costs or any rule; only read state.
- No object may use `visible=false` as its only state at boot if it is ever shown: use
  `count=0` / zero scale (the warm-up must compile them).
- Exact string replacement only. You cannot see the page: the orchestrator screenshots a night
  started with `__dao.def.startNight()`.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block; list the new draw calls and their capacities.
