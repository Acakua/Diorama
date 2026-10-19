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
| 4A | home | End flat by the west window. |
| 4B | ajar | Mr. Hale's flat, next door. Lootable. |
| 4C | locked, "Nobody answers"; spare key under the ficus by 4A (knowledge gate) | Mrs. Okafor (70s) left with her son Daniel on day 1. |
| 4D | locked | Slice 3: survivor inside (Nadia, 19, student). Faint radio music behind the door. |
| Stairwell | blocked: a heap of chairs and a mattress piled on the landing | East end. Someone barricaded the stairs from below on day 2. The infected squeeze through at night. |

West end: a tall window with the evening sun; the renovation pile (planks) under it; a dead
potted ficus between 4A and 4B. A fire-hose cabinet (empty, glass cracked) between 4C and 4D.

Windows only on outside walls. 4A is the end flat: its window is on the west front, with the
corridor window, and gets the low evening sun (home's back wall; the corridor glimpse in the home
scene ends at that same west wall). 4B-4D sit in the middle of the row, so their only outside
wall is the north one, opposite their door: in the flat scenes that is the cut-away +X wall
(sill, radiator and curtain ends at the cut; shadow-only casters shape the light). North
windows get no direct sun (Daylight.sky). The back (-Z) walls of 4B and 4C are shared with the
flat to the west. In the home scene the zombie comes along the corridor from +Z: from the stairs.

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
- Renovation pile under the west window: **2 planks** (search).
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

## Sound (director's notes)

- Outside, through every window: the city three days in. By day few cars, wind, birds, a siren
  somewhere and a helicopter far off (it plants the rooftop pickups before the letter names
  them). At night wind, a fainter siren, one distant crash. 4A's west window hears the street;
  the north windows of 4B/4C are a courtyard, quieter.
- Room tone: home and 4C have ticking clocks; 4B's fridge still hums (power is on); the
  corridor bulb buzzes. Footsteps: boards in the flats, the runner in the corridor.
- Hale: a dragging step, groans, and ragged breathing that is loudest when he stands still at
  the door. All of him is muffled through the door and walls (OccludedSound) and clears when the
  door opens: opening it to look is a mistake you can hear.

## Later slices (not built)

- Slice 2: Hale (and others) roam floors 3-5 by day; stealth using the same light/noise rules;
  the stairwell opens; floor 3 (laundry room, 3B with a dog?).
- Slice 3: Nadia in 4D. Talks through the door on night 2 if the player listened to her radio
  frequency. Can be brought to 4A: eats food, can hold the door, panics in the dark.
- Slice 4: runs of 5 days to the evacuation (rooftop helicopter on day 5 at 10:00, announced by
  radio on night 3), food as the clock, events deck (power cuts, a looter, a fire on floor 6).


## The core mystery (three layers)

The player uncovers these across runs through fragments. Never state them outright in one place.

1. **What happened to Mr. Hale.** The "stray" that bit him was Biscuit, the caretaker Walt
   Brenner's terrier. Biscuit came back sick from the park where the first cases appeared (day 0).
   Hale covered for his friend ("a stray on Elm St."). Fragments: Hale's notes, a photo of Walt and
   Biscuit in 4B (later), dog hair and a leash in the basement (later).
2. **Who blocked the stairs, and why.** Walt barricaded the stairwell below floor 4 on day 2 to keep
   Hale (his friend, turned) away from the families on floors 1-3. He knew people were still on
   floor 4. Guilt is his whole character. He lives in the caretaker's flat in the basement with the
   master keys.
3. **The way out.** The radio will announce rooftop pickups for buildings with roof access ("day 5,
   10:00"). The roof door is locked; Walt has the master key. Reaching him means getting past the
   barricade and down through floors 3-1. That is the run's end goal (later slices).

Supporting truth (gameplay explained by lore): **the infected keep routines.** They drift back
"home" at night and to familiar places by day. That is why Hale returns to floor 4 every night.
Nadia (4D, nursing student) has worked this out; her notebook is a later fragment.

## Journal

Autoload `Journal` (scripts/game/journal.gd), saved to user://journal.json, kept across runs and
sessions. Categories: clues, notes, people, places. Ids in use:

| Id | Category | Learned from | Unlocks |
|---|---|---|---|
| place_home / place_corridor / place_4b / place_4c | places | entering | - |
| note_hale_table, note_hale_bed | notes | reading in 4B | - |
| note_hale_calendar | notes | 4B kitchen calendar | clue_okafor_key |
| clue_okafor_key | clues | the calendar | "Under the Ficus" by 4A (gives the 4C key) |
| note_daniel_letter | notes | 4C table | clue_roof_keys |
| clue_roof_keys | clues | the letter | later: the roof |
| person_hale | people | peephole while he is at the door | - |
| clue_dark_quiet | clues | he leaves a dark, quiet door | - |
| clue_planks_tear | clues | a plank torn off | - |

## 4C, Mrs. Okafor's flat (journal slice)

Tidy, plant-filled, knitted throws, sewing table, family photos. She left with her son Daniel on
day 1. Loot (rolled on first visit): dresser 2 batteries; hall closet 1 plank; sewing table drawer
1 battery (50%); bookshelf nothing ("Books, and an album full of grandchildren."). On the table:
Daniel's letter (note_daniel_letter):

> Mum - I'll pick you up Monday at 9. If the phones are down, wait inside. Walt says he'll keep the
> master keys on him, roof too, in case they start those rooftop pickups they keep talking about
> on the news. - D.
