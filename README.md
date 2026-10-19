# Diorama Room 01

An isometric, low-poly survival game in Godot 4.7, set in an apartment building in the first
days of an outbreak. By day you leave your room to search the building; by night you hold the
room with what you brought back. A lost run starts over, but the **journal** keeps what you
learned (notes, people, places, clues), and some things only show up once you know about them.
The rules are in [docs/design.md](docs/design.md).

> **`content/` holds the game's content (places, story, events, item spots, the night scripts)
> and is kept secret from the player. Don't open it if you want to play unspoiled.**

## Run

On Windows, double-click **`play.bat`**. Otherwise open the folder in Godot 4.7 and press F5, or:

```
godot --path .
```

### On a new machine

1. Clone the repo: `git clone https://github.com/Acakua/Diorama.git`
2. Download Godot **4.7.2 (standard, not .NET)** from
   https://github.com/godotengine/godot/releases/tag/4.7.2-stable and unzip it to
   `%USERPROFILE%\Godot\` (that's where `play.bat` looks), or set `GODOT` to the executable.
3. Double-click `play.bat`. The first start imports the assets (a few seconds); nothing else
   needs installing. Python is only needed to regenerate the sounds (`tools/make_sounds.py`).

Mouse only: hover an object to see what a click does; **left click** the floor to walk there
(pathfinding) or an object to walk up and use it; **right click** an object for its other
actions; click again to stop; the on-screen *Flashlight* button toggles the light and *Journal*
opens the journal (the game pauses while it is open). The keyboard
still works:

| Key | Action |
|---|---|
| W A S D / arrows | Move (relative to the camera) |
| E | Use the highlighted object (hold E to search or pry) / pick up, put down, wedge the chair |
| F | Second action (look through the peephole, close a cabinet) |
| R | Use something from the bag on it (nail a plank, hold) / new run on the end screen |
| Q | Flashlight on / off |
| J | Journal (Esc closes it) |
| Mouse wheel | Zoom |
| F3 | Debug overlay (FPS, position, target, phase, run seed) |
| Esc | Quit |

## Layout

```
scripts/game/         game_state.gd (autoload: run, clock, bag, travel, noise), journal.gd (autoload:
                      what is known, kept across runs), place.gd, place_exit.gd, inventory.gd, items.gd
scripts/interaction/  interactable.gd (base: prompts, hold actions, items, second action),
                      interaction_detector.gd, carryable.gd, searchable.gd, readable.gd
scripts/night/        night_director.gd (clock, beats, win/lose; each night extends it)
scripts/zombie/       zombie.gd (paths, attention from light and noise, knocks and bangs)
scripts/objects/      door (hinge, barricades, peephole), cabinet, radio, light switch, lamp, clock
scripts/player/       player_controller.gd (movement + action sequence), player_animation.gd
scripts/world/        daylight.gd (window light from the clock)
scripts/camera/       iso_camera.gd
scripts/ui/           hud, pointer (mouse play), journal view, focus marker, peephole view, night overlay
scripts/audio/        ear (the listener, at the player's head), footsteps, occluded sound (muffled
                      through walls, clear through open doors), ambience (window loops by day/night)
scenes/               the home room, shared objects, furniture, player, zombie, UI
assets/               materials, shaders, sounds (synthesised by tools/make_sounds.py)
content/              hidden: places, night scripts, content items (content.gd), content tests, bible.md
```

To add a usable object, extend `Interactable` and override `get_prompt()` and `_on_interact()`
(plus `get_hold_time()`, `get_item_prompt()` / `_on_use_item()` or `get_secondary_prompt()` as
needed). Anything in the group `persistent` with `get_state()` / `set_state()` is remembered
when the player leaves a place. Set `requires_knowledge` on an interactable to hide it until the
journal knows that id.

## Sound

Every sound is synthesised by `tools/make_sounds.py` (no samples): struck objects are built from
their resonant modes, voices from glottal pulses and formants. 3D sounds play on the `World` bus
(`default_bus_layout.tres`), whose reverb each place sets (`Place` > Sound: room size, damping,
wet, and the floor the footsteps use). The game listens from the player's head (`Ear`), so
distance and left/right follow what is on screen. An `OccludedSound` switches to the `Muffled`
bus while a wall or closed door is in the way.

## Checks

```
godot --headless --path . res://tests/smoke_test.tscn        # loads every place
godot --headless --path . res://tests/acceptance_test.tscn   # the room's interactions (exit code = failures)
godot --headless --path . res://tests/pointer_test.tscn      # mouse: hover, click to walk/use, right-click menu
godot --headless --path . res://tests/audio_test.tscn        # listener, footsteps, muffling, echo, day/night loops
godot --headless --path . res://content/tests/slice1_test.tscn   # a whole day and night (spoilers in its output)
godot --headless --path . res://content/tests/journal_test.tscn  # the journal across runs (spoilers in its output)
godot --path . res://tests/fps_probe.tscn                    # average / worst frame time
```
Run a test without `--headless` to also save screenshots to `tests/screens/`. Tests never touch
the player's journal; it lives in Godot's user folder (`user://journal.json`), and *Forget
everything* in the journal clears it.
