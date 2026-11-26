# AD1 — Art bible and first review of the current look

## Objective
The project has no art bible. Every later visual change (by you or by opencode workers) must be
judged against one. Write `design/art-bible.md` that captures the look the island already has at
its best, names what is off, and sets the rules and review criteria. Then review the current
screenshots against it and write a prioritised, numbered critique the orchestrator can turn into
fix briefs. **This round you do not edit `dao-coi-nuoc.html`.**

## Read first
- `tools/orchestra/ART-DIRECTOR.md` (your charter), `design/game-brief.md` (whole; short).
- Screenshots: every image in `.orchestra/shots/AD1/` with its `shots.md`; open each one.
  Reference: `production/qa/evidence/perf-shader-warmup/*.jpg`, `production/qa/evidence/mun-ledger/*.jpg`.
- `dao-coi-nuoc.html`, only to collect real values. Search (do not read the whole file) for:
  `applyTime` (sky/light per hour), `buildWeather`, `Seas` (seasons), `const Wx=`, `Fog`,
  `HemisphereLight`, `DirectionalLight`, `MeshToonMaterial|MeshStandardMaterial`, `0x` colour
  constants near those, and the `<style>` block (UI colours and fonts).

## Files you may change
- Create `design/art-bible.md`.
- Create `production/art/AD1-review.md`.
- Nothing else.

## Spec: `design/art-bible.md` (Vietnamese prose; hex/constants as-is), sections in this order
1. **Ý tưởng hình ảnh**: mood in 3–5 sentences, 3 visual pillars, 3 reference touchstones
   described in words (no copyrighted art reproduced), what this island must never look like.
2. **Bảng màu**: base palette (8–14 hex with role), and per time of day (dawn, noon, sunset,
   night) and per season (spring, summer, autumn, winter) the key sky / light / foliage /
   ground colours. Mark which values are current (found in code, give the constant or function
   name) and which are proposed.
3. **Ánh sáng**: sun, hemisphere/ambient, night lamps and windows, fog; intended contrast and
   warmth per time of day.
4. **Hình khối và vật liệu**: scale of the island, shape language (round vs angular, chunky vs
   thin), material families (wood, stone, roof, foliage, water, crystals under the island), level
   of texture detail, depth of field use.
5. **Nhân vật**: how Linh (VRoid toon model) and the hens/koi/Mun sit with the scenery: outline,
   saturation, readability at the default camera distance.
6. **Hiệu ứng và thời tiết**: rain, storm, snow, fireflies, magic, the protective dome, clouds.
7. **Giao diện**: UI cards and HUD colours, type, corner radius, how they relate to the scene.
8. **Tiêu chí duyệt** (review criteria): 6–8 lettered criteria (a), (b)… each testable from a
   screenshot (e.g. "(c) the focal object of each shot reads in under 1 s at 1280×720"). Later
   rounds report pass/fail against exactly these letters.
9. **Ngân sách**: performance rules from your charter (boot-compiled shaders, no new passes).

## Spec: `production/art/AD1-review.md`
- One short paragraph per screenshot (what works, what does not).
- Then a numbered list of issues across all shots, sorted P1 → P3. Each: shot file(s), the
  problem, the concrete fix (value, hex, constant/function to change), expected cost (none /
  small / needs a new material).
- Then "Không phải lỗi": things in the shots that come from the forced-season transition
  (see `shots.md`) and must not be fixed.
- End with the 3 changes you would do first as the next round (AD2), each in one sentence.

## Constraints
- Do not edit any other file. Do not run git commands that change anything.
- Judge only what you can see in the shots; say "chưa thấy" for anything not shown (e.g. dawn).
- Keep the art bible under about 350 lines; concrete beats long.

## Done when
- Both files exist; the art bible has the 9 sections above, the review has the issue list.
- `git status --short` shows only those two new files (plus nothing in tracked files).

## Return
The report block from `ART-DIRECTOR.md` (VERDICT: judge the current shots against your new
criteria).
