# Diorama Room 01

A single-room, isometric, low-poly diorama prototype in Godot 4.7 for checking that the
"small room + player interaction" loop feels good. It has no zombies, combat or survival
systems; those come only after playtesting this room.

## Run

Open the folder in Godot 4.7 and press F5, or:

```
godot --path .
```

| Key | Action |
|---|---|
| W A S D / arrows | Move (relative to the camera) |
| E | Use the highlighted object |
| Mouse wheel | Zoom |
| F3 | Debug overlay (FPS, position, current target) |
| Esc | Quit |

## Layout

```
scenes/room/       room_01 (main), door, cabinet, window, light_switch, ceiling_lamp, radio
scenes/furniture/  bed, bedside_table, desk, chair, rug, plant, trunk, picture, wall_clock, calendar
scenes/player/     player (procedural low-poly body)
scenes/ui/         hud
scripts/interaction/  interactable.gd (base: prompt, interact, stand point), interaction_detector.gd
scripts/objects/      interactive_door / cabinet / radio, light_switch, ceiling_lamp
scripts/player/       player_controller.gd (movement + use sequence), player_animation.gd (walk/idle/reach)
scripts/camera/       iso_camera.gd
scripts/util/         bevel_box_mesh.gd (chamfered box primitive used for all furniture)
assets/materials/  shared palette (.tres), assets/shaders/wood_planks.gdshader
assets/audio/      synthesised by tools/make_sounds.py
```

To add a new usable object, extend `Interactable`, override `get_prompt()` and
`_on_interact()`, and optionally `get_stand_position()` if it swings toward the player.

## Checks

```
godot --headless --path . res://tests/acceptance_test.tscn   # scripted walk-through, exit code = failures
godot --path . res://tests/acceptance_test.tscn              # same, plus screenshots in tests/screens/
godot --path . res://tests/fps_probe.tscn                    # average / worst frame time
```
