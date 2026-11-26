# PERF3 — Low-poly shadow proxies for the terrain and the island bowl

## Objective
The shadow pass (one 2048² directional map, refreshed about 24 times a second) draws 171 casters,
about 980k triangles. Measured by the orchestrator: two static meshes are over a third of it:
- the **terrain** (built in `buildTerrain`): 327,080 triangles, 26 × 3.3 × 26 m, `castShadow` and `receiveShadow` true;
- the **island bowl** (built in `buildBowl`, kept in `Deep.bowlMat`'s mesh): 45,840 triangles, 26 × 12 × 26 m, DoubleSide.
Keep both meshes for colour (they still receive shadows) but stop them casting; cast instead from
two invisible low-poly proxies that exist **only in the shadow pass**. Same picture, far fewer shadow triangles.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: `function buildTerrain(`, `function buildBowl(`, the helpers `hAt` / `groundAt`
  (terrain height), the island constant `R` (13), and where the directional sun light and its
  `shadow.camera` are created (search `DirectionalLight(`).
- three.js r170 layers: the shadow pass renders objects whose `layers` test against
  `light.shadow.camera.layers`; the main camera renders layer 0 only.

## Files you may change
- `dao-coi-nuoc.html` only: `buildTerrain`, `buildBowl`, and the line(s) right after the sun light's
  creation (to enable layer 1 on `sun.shadow.camera.layers`). Nothing else.

## Spec
- Terrain proxy: a grid of 96 × 96 quads over the island disc (skip quads fully outside radius R+0.1),
  vertex y = the same height function the terrain uses, minus 0.03 (so the real surface does not
  self-shadow from the proxy: no acne). `MeshBasicMaterial({colorWrite:false})` is fine (only depth
  matters); `castShadow = true`, `receiveShadow = false`; `proxy.layers.set(1)`; add it to the same
  parent as the terrain. Real terrain: `castShadow = false` (keep `receiveShadow = true`).
- Bowl proxy: rebuild the bowl's outer surface with about 48 radial segments and 12 rings (whatever
  profile `buildBowl` uses, coarser), same transform, `side: THREE.DoubleSide`, layer 1 only,
  `castShadow = true`. Real bowl: `castShadow = false`.
- `sun.shadow.camera.layers.enable(1)` so the shadow pass sees layer 1 (keep layer 0 enabled too).
- Both proxies are created at boot (inside those build functions) so the shader warm-up covers them.

## Constraints
- No other visual change: do not change materials, colours, light values, shadow map size or bias.
- Edit by exact string replacement only. Do not touch `foldRigid`/`freezeStatic`.
- You cannot see the page; the orchestrator compares screenshots at 07:00, 12:00 and 18:00
  (long shadows) and counts shadow triangles.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block, plus the proxies' triangle counts (computed from your grid sizes).
