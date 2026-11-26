# PERF1 — Stop recomputing the matrices of objects that never move

## Objective
The page is CPU-bound. Measured by the orchestrator on 2026-11-26 at 2560×1270, quality "high":
bench 9.6–10.4 ms per frame, CPU about 7.4–9.2 ms, about 500 draw calls. The scene has 1179
objects and 1121 of them have `matrixAutoUpdate = true`, so `scene.updateMatrixWorld()` recomposes
every local matrix each frame: about **1.0 ms per frame**. Most of those objects never move.
Freeze the static ones once after boot so a frame only recomposes objects that can move.
Same picture, less CPU.

## Read first
- `AGENTS.md`.
- `dao-coi-nuoc.html`, function `foldRigid` (search `function foldRigid(){`, about line 2583):
  it already builds `held`, the set of every `Object3D` and material that game code keeps a
  reference to (through `AG, Cine, Crit, Crit2, Deep, Ev, Life, Magic, P_, Place, V, anim, furn,
  hens, pool, hv, mv, vq, Seas`). Objects in `held` (and their subtrees) can be moved by code.
- The boot line (search `Seas.build();perfInit();Inner.scan();trimCasters();`), where
  `window.__dao.perf.fold=foldRigid()` runs. Your freeze runs right after `foldRigid()`.

## Files you may change
- `dao-coi-nuoc.html` only: `foldRigid` (to return or expose `held`), one new function
  `freezeStatic(held)`, its call on the boot line, and one new debug method
  `window.__dao.perf.staticCheck`. Nothing else.

## Spec
```js
// Returns {frozen, kept}. An object is frozen when: it is not in `held`, no ancestor is in
// `held`, no descendant is in `held`, it is not a SkinnedMesh/Bone/Camera/Light target,
// it is not under the VRM scene (Linh), not under anim.roof, and it has no custom onBeforeRender.
function freezeStatic(held){ /* o.updateMatrix(); o.matrixAutoUpdate=false; */ }
// Debug: for every frozen object, recompose its matrix from position/quaternion/scale and
// compare with o.matrix; returns {frozen, moved:[names or uuids of objects whose transform
// changed since freezing]}. The orchestrator runs it after cycling hours, seasons, weather
// and the roof, so it must not change any state.
window.__dao.perf.staticCheck = () => ({frozen, moved});
```
Keep `matrixWorldAutoUpdate` as it is: world matrices of frozen children still follow their
parents through `updateMatrixWorld`; only the local recompose is skipped.

## Steps
1. Make `foldRigid` keep `held` reachable (return it in its result or store it in a module variable).
2. Write `freezeStatic(held)`: walk `scene`; compute the "dynamic" set = held objects, all their
   ancestors and all their descendants, plus the exclusions above. Freeze everything else.
   Store the frozen list for `staticCheck`.
3. Call it on the boot line right after `foldRigid()`; store the counts in
   `window.__dao.perf.frozen`.
4. Write `staticCheck` as specified.

## Constraints
- No visual change of any kind. Do not touch materials, lights, colours or `foldRigid`'s merge logic.
- Edit by exact string replacement; do not reformat other code.
- You cannot run the page. The orchestrator will measure and run `staticCheck`.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html`.

## Return
The AGENTS.md report block. In RISKS name any kind of object you think could still move while frozen.
