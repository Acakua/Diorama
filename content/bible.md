# Content bible (hidden from the player)

Claude is the game's director. The user plays it unspoiled and has asked not to see this.
Rules for any future session:

- Never quote this file, event timings, loot spots or story beats in chat. Summaries say
  things like "added two events to night 2", not what they are.
- Public rules live in `docs/design.md`; anything a player could only learn by playing lives
  here or elsewhere under `content/`.
- Use `GameState.rng` (seeded per run) for every content roll so runs differ.
- Content-specific tests live in `content/tests/` (they reveal layout, so they stay here).

## Setting

Ashgrove Court, an eight-storey 1970s block in a mid-sized city. October. The outbreak is three
days old; the news still calls it "violent attacks" and "a fever". The player character lives
alone in **4A** on the fourth floor. Most residents fled on day 1 or locked themselves in.

## Floor 4 (slice 1)

Corridor runs west to east. Doors on its north wall, from west to east:

| Door | State in slice 1 | Notes |
|---|---|---|
| Stairwell | blocked: a heap of chairs and a mattress piled on the landing | Someone barricaded the stairs from below on day 2. The infected squeeze through at night. |
| 4D | locked | Slice 3: survivor inside (Nadia, 19, student). Faint radio music behind the door. |
| 4C | locked, "Nobody answers" | Mrs. Okafor (70s) left with her son on day 1. Slice 4: keys under the mat on a later day. |
| 4B | ajar | Mr. Hale's flat. Lootable. |
| 4A | home | |

East end: a tall window with daylight; a dead potted ficus; a fire-hose cabinet (empty, glass
cracked) and a small renovation pile (planks).

## Mr. Hale (the thing at the door)

Retired bus driver, 4B, polite, lonely. Bitten on day 2 "by a dog" on his way home, bandaged it
himself, wrote a note, felt feverish, went to the stairwell for air. He turned that night. He
still drifts back to floor 4 every night: home. His flat tells the story through two notes and
a bloody bandage by the sink. Night 1's peephole thought names him.

## Slice 1 content

### 4A (home)
- The player's cabinet is searchable once open: **flashlight** (with one battery inside) and
  **1 battery**. The lantern stays as decoration.
- Radio bulletins at day/night times (see night script).

### Corridor
- Renovation pile near the east window: **2 planks** (search).
- Fire-hose cabinet: empty, with a scrawled "SORRY" on the glass (flavour).

### 4B (Hale's flat), seeded
Containers and what can be in them (rolled once per run on first visit):
- Toolbox under the sink: **hammer** (always here: the night must be solvable).
- Hallway closet: **2 planks** (bed slats he pulled out).
- Bedroom wardrobe: **1 plank** or nothing (50%).
- Kitchen drawer / nightstand / desk drawer: **2 batteries** spread over two of the three.
- Bathroom cabinet, fridge: nothing useful (fridge: "It smells.").
- Notes: kitchen table ("Bitten by a stray on Elm St. It's nothing. Cleaned it. — H."),
  bedside ("Can't get warm. Going to sit on the stairs where it's cool. If you find this, Walt,
  the spare key is in the bus tin.").

Totals per run: hammer 1, planks 4-5 (2 corridor + 2-3 flat), batteries 3 (1 home + 2 flat).
Bag is 3 slots, planks stack 2, batteries stack 3, so a full haul needs two trips or choices.

### Night 1 (v2) — `content/nights/night_01.gd`
Night runs from arrival at home after dusk (normally 20:00) to 05:30.

1. 20:30 bulletin: stay in, lights low, do not open doors. (Only if the radio is on.)
2. Hale's visits: three visits before the assault, each starts with shuffling from the
   stairwell end, then probing knocks at the door. Visit start times are jittered by the run
   seed. Each visit lasts until he gets bored (dark and quiet for ~15 s) or until a cap.
   Between visits, quiet lulls are the windows for noisy work (nailing).
3. Noise while he is away (hammer, radio) makes the next visit start sooner.
4. 01:00 bulletin: "they are drawn to light and sound", "board up your doors".
5. Assault from 04:00: he bangs non-stop for ~55 s. Heavy hits can tear a plank off.
6. 05:00 he wanders off; 05:10 bulletin about daylight and an evacuation being organised
   "in the coming days" (hook for the run structure).
7. 05:30 dawn: survived. Slice 1 ends with "Day 2" and a "to be continued" card.

If the player is outside at 20:00 they hear Hale coming up the stairs; they have ~25 s to get
home. Arriving late starts the night with his attention already raised.

### Balance targets
- Door 100 HP. Chair wedge x0.6; each plank -0.2 (three planks x0.4); they multiply.
- Normal visit: hard knock 0.6 dmg, bang 1.5 dmg; tear chance 25% per bang with planks.
- Assault: bang 2.5 dmg every ~1.1 s for ~55 s (~125 raw).
- Careless (lights/radio on, no barricade): loses around midnight.
- Stealthy, chair only: loses late in the assault.
- Stealthy, chair + 3 planks, no repairs: survives narrowly.
- Active (re-nails during lulls and the assault, spare planks, flashlight): survives clearly.

## Later slices (not built)

- Slice 2: Hale (and others) roam floors 3-5 by day; stealth using the same light/noise rules;
  the stairwell opens; floor 3 (laundry room, 3B with a dog?).
- Slice 3: Nadia in 4D. Talks through the door on night 2 if the player listened to her radio
  frequency. Can be brought to 4A: eats food, can hold the door, panics in the dark.
- Slice 4: runs of 5 days to the evacuation (rooftop helicopter on day 5 at 10:00, announced by
  radio on night 3), food as the clock, events deck (power cuts, a looter, a fire on floor 6).
