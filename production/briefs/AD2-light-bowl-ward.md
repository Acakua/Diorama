# AD2 — Fix the four P1 looks from the AD1 review

## Objective
Apply the four P1 fixes of `production/art/AD1-review.md` (issues 1–4) to the art of
`dao-coi-nuoc.html`, so that the next screenshots pass art-bible criteria (b), (c) and (e), and
improve (a) at sunset and night. You are the art director: you may adjust the values proposed in
your own review if, on reflection, others fit the art bible better. Write down the final values.

## Read first
- `tools/orchestra/ART-DIRECTOR.md`, `design/art-bible.md` sections 2, 3, 4, 8, 9.
- `production/art/AD1-review.md` issues 1–4 (lines 45–67).
- Shots to compare against: `.orchestra/shots/AD1/03-autumn-1800-sunset.jpg`, `04-autumn-2200-night.jpg`,
  `01-autumn-0700-morning.jpg`, `08-winter-1100-snow-after30s.jpg`, `07-summer-1600-storm.jpg`.
- In `dao-coi-nuoc.html` search for: `STOPS`, `applyTime`, `stepPlaces`, `// night-life lights`,
  `buildBowl`, `buildTerrain` (the `lip` colour), `buildWeather`, `addSnow`, `buildPlaces`, `Place.ward`, `hexd`.

## Files you may change
- `dao-coi-nuoc.html`, only in these places:
  1. `STOPS` values (sky, sun, light intensities) for the sunset (17.5–19.2 h) and night stops.
  2. The lamp/window/porch **light thresholds and intensities** inside `stepPlaces` and the
     `// night-life lights` block (when and how bright the warm lights come on).
  3. `buildBowl` material (roughness, colours) and keeping a reference to it; calling `addSnow`
     on it inside `buildWeather` (boot time, before the shader warm-up).
  4. The `lip` colour mix in `buildTerrain`.
  5. The **shader look** of `Place.ward` in `buildPlaces` (pattern, colour, brightness).
- `design/art-bible.md`: update the palette/light tables to the values you finally chose.
- Create `production/art/AD2-notes.md`: every value changed, old → new, and why.

## Not yours this round (write under REQUESTS, an opencode worker does it in AD2b)
- **When** the ward is shown (`Wd.t` reset, `Wd.d.visible`, the `wards` chore state) — that is logic.
- `fireOn` and anything tied to Linh's schedule or `inhab`.
- The far islands, DOF, Linh's rim light, gable walls, sky lower half, storm colour: later rounds.

## Constraints
- No new `ShaderMaterial`, no new `onBeforeCompile` key, no new render pass or shadow caster.
  `addSnow` on the bowl must run at boot (inside `buildWeather`) so the warm-up compiles it.
- Edit by exact string replacement; do not reformat lines you do not change.
- No git commands that change anything. Do not start servers or browsers; you will not see the result.

## Done when
- `node tools/orchestra/check-page.mjs dao-coi-nuoc.html` prints `0 failed`.
- `git diff --stat` shows only `dao-coi-nuoc.html` and `design/art-bible.md`, plus the new
  `production/art/AD2-notes.md`.
- `AD2-notes.md` lists each change with old and new value.

## Return
The report block from `ART-DIRECTOR.md`. VERDICT: "not judged" for every criterion (you have not
seen the result); the orchestrator will shoot new screenshots and run you again for the verdict.
