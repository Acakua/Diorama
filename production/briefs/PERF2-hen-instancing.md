# PERF2 — Draw the hens' flame tails and combs as two instanced meshes

## Objective
The page is CPU-bound by draw calls (about 500 per frame plus the shadow pass). Measured by the
orchestrator: the 5 hens cost **70 draw calls, 45 of them also in the shadow pass**. 50 of those
are tiny `flameGeo` lathe meshes: per hen 7 tail flames (material `emb`, `Crit.henGlow`) and 3 comb
flames (material `combM`), each its own Mesh because `stepHens` animates its `scale.y` every
frame. Draw all 35 tail flames as ONE `THREE.InstancedMesh` and all 15 comb flames as ONE more.
Same picture, about 48 fewer draw calls per pass.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`: `function buildHens(` (about line 2298) and `function stepHens(` (about
  line 2312). Only these two functions use `e.tail`, `e.comb` and `Crit.henGlow`.
- The boot line (search `Seas.build();perfInit();`): `foldRigid()` and `freezeStatic()` run after
  `buildHens`; objects in the `hens` array are "held" and stay dynamic.

## Files you may change
- `dao-coi-nuoc.html`, only `buildHens` and `stepHens`.

## Spec
- In `buildHens`: keep creating each flame's local transform exactly as now (position, rotation,
  base scale, parent `g` or `nk`), but as a plain `THREE.Object3D` "slot" (not a Mesh) added to the
  same parent, so the hen hierarchy still carries it. Keep `e.tail` / `e.comb` as arrays of these
  slots; `stepHens` keeps writing `slot.scale.y` as now.
- After the loop create `Crit.henTails = new THREE.InstancedMesh(flameGeo, emb, 35)` and
  `Crit.henCombs = new THREE.InstancedMesh(flameGeo, combM, 15)`; `castShadow = true`
  (as the meshes were), `receiveShadow` as before (false), `frustumCulled = false`,
  `instanceMatrix.setUsage(THREE.DynamicDrawUsage)`; add both to `scene`. Fill their matrices
  once at the end of `buildHens` so the first frame is right.
- At the end of `stepHens` (after all hens moved and slot scales were set): for each hen,
  `e.g.updateMatrixWorld(true)`, then for each slot `setMatrixAt(i, slot.matrixWorld)`; set
  `instanceMatrix.needsUpdate = true` on both meshes. Reuse no temporary objects per frame
  beyond what three needs (no `new` inside the loop).
- `Crit.henGlow` stays the `emb` material, so the night glow keeps working.

## Constraints
- No visual change: same geometry, materials, colours, sizes, animation, shadows.
- The new meshes are created at boot inside `buildHens`, so the shader warm-up compiles them.
  Do not create any material or mesh later.
- Edit by exact string replacement; do not touch any other function.
- You cannot see the page. The orchestrator measures draw calls and compares screenshots.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`, and the diff touches only `buildHens` and `stepHens`.

## Return
The AGENTS.md report block. Under RISKS: anything that could make a flame lag one frame behind
its hen, or vanish (bounding volume, culling, shadow).
