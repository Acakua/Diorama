# AD3 — Judge the AD2 result, then fix what still fails

## Objective
AD2 changed sunset/night light, the island bowl, the lip colour and the ward shader (your notes:
`production/art/AD2-notes.md`; the edits are in the working tree, uncommitted). The orchestrator shot
the same cameras again. First judge the new shots against art-bible criteria (a)–(g) and against
AD1, then fix what still fails, including the P2 issues 5–8 of `production/art/AD1-review.md`.
Iterate in your head toward the best result you can justify; the orchestrator will shoot again.

## Read first
- `tools/orchestra/ART-DIRECTOR.md`, `design/art-bible.md` (sections 2–4, 6, 8, 9).
- `production/art/AD1-review.md` (issues 5–11), `production/art/AD2-notes.md`.
- Shots: `.orchestra/shots/AD2-r2/` with its `shots.md` (open every image), and the same file
  names in `.orchestra/shots/AD1/` for before/after.
- `git diff dao-coi-nuoc.html` shows exactly what AD2 changed.

## Files you may change
- `dao-coi-nuoc.html`, art only, in these places: everything AD2 touched (`STOPS`, the light
  thresholds/intensities in `stepPlaces` and `// night-life lights`, `buildBowl`, the `lip` in
  `buildTerrain`, the `Place.ward` shader), plus: `skyMat` (lower half of the sky), the storm tint
  in `applyTime` (`stormK`/overcast colours), far islands in `buildDepths` (colours, snow via
  existing `addSnow`/uniforms), `styleLinh` (MToon rim/colour factors only), Nimbus colour in
  `buildCreatures2`, DOF amount in `prepQ`/`dofQ` uniforms, `Magic.wisp` colour/intensity.
- `design/art-bible.md`: keep tables in sync with final values.
- Create `production/art/AD3-review.md`: verdict per shot, criteria table (a)–(g) for AD1 vs
  AD2-r2, then every change of this round (old → new, why).

## Constraints
- Same hard rules as AD2: no new `ShaderMaterial`, no new `onBeforeCompile` key, no new pass or
  shadow caster; every material must exist at boot. Ward **visibility timing** is logic: do not
  touch `Wd.t`, `Wd.d.visible` or `AG` state; only how the ward looks while visible.
- Performance matters as much as looks (owner's request): do not raise sample counts, shadow
  map sizes or overdraw; if a change can make a frame cheaper at the same look, prefer it and
  say so in the notes.
- Exact string replacement only; no reformatting; no git commands that change anything.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git status --short` shows only `dao-coi-nuoc.html`, `design/art-bible.md` and files under `production/art/`.
- `AD3-review.md` exists with the criteria table and the change list.

## Return
The `ART-DIRECTOR.md` report block. VERDICT = your judgement of the AD2-r2 shots (before this
round's edits); list under RISKS anything you changed but could not see.
