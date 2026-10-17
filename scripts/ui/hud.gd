class_name Hud
extends CanvasLayer
## Minimal HUD: one prompt line at the bottom ("[E] action", plus "[F]" and
## "[R]" actions when the object has them) with a small ring over the object
## it refers to (it fills while an action is held), a short status line after
## each interaction, the bag and tools in the corner, and an F3 debug readout
## that starts hidden.

@export var player: PlayerController

const STATUS_HOLD := 1.6
const STATUS_FADE := 0.5
## Prompt offsets from the bottom edge (px); it rises a little as it appears.
const PROMPT_TOP := -100.0
const PROMPT_BOTTOM := -44.0
const PROMPT_RISE := 8.0

var _prompt_alpha := 0.0
var _status_time := 0.0
var _shown := PackedStringArray(["", "", ""])

@onready var _marker: FocusMarker = $Marker
@onready var _prompt: Control = $Prompt
@onready var _keys: Array[Control] = [$Prompt/Box/Row/Key, $Prompt/Box/Row/Key2, $Prompt/Box/Row/Key3]
@onready var _actions: Array[Label] = [
	$Prompt/Box/Row/Action, $Prompt/Box/Row/Action2, $Prompt/Box/Row/Action3]
@onready var _status: Label = $Status
@onready var _bag: Label = $Bag
@onready var _debug: Label = $Debug


func _ready() -> void:
	_prompt.modulate.a = 0.0
	_marker.modulate.a = 0.0
	_status.modulate.a = 0.0
	_debug.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		_debug.visible = not _debug.visible


## Primary action currently offered, e.g. "[E] Open Cabinet", or "".
func get_prompt_text() -> String:
	return _chip(0, "E")


## Secondary action currently offered, e.g. "[F] Look Through Peephole", or "".
func get_secondary_prompt_text() -> String:
	return _chip(1, "F")


## Item action currently offered, e.g. "[R] Nail Plank (hold)", or "".
func get_item_prompt_text() -> String:
	return _chip(2, "R")


func show_status(text: String) -> void:
	_status.text = text
	_status_time = STATUS_HOLD + STATUS_FADE


func _process(delta: float) -> void:
	var prompts := player.get_prompts() if player else PackedStringArray(["", "", ""])
	var show := prompts[0] != "" or prompts[1] != "" or prompts[2] != ""
	if show and prompts != _shown:
		_shown = prompts
		for i in 3:
			_actions[i].text = prompts[i]
			_actions[i].visible = prompts[i] != ""
			_keys[i].visible = prompts[i] != ""
	var target := player.get_prompt_target() if player else null
	if target and player.camera:
		_marker.position = player.camera.unproject_position(target.get_interaction_position())
	_marker.progress = player.get_hold_progress() if player else 0.0
	var holding: bool = _marker.progress > 0.0
	_prompt_alpha = move_toward(_prompt_alpha, 1.0 if show and not holding else 0.0, delta * 7.0)
	_prompt.modulate.a = _prompt_alpha
	var marker_to := 1.0 if target and (show or holding) else 0.0
	_marker.modulate.a = move_toward(_marker.modulate.a, marker_to, delta * 7.0)
	var rise := (1.0 - _prompt_alpha) * PROMPT_RISE
	_prompt.offset_top = PROMPT_TOP + rise
	_prompt.offset_bottom = PROMPT_BOTTOM + rise

	_status_time = maxf(0.0, _status_time - delta)
	_status.modulate.a = clampf(_status_time / STATUS_FADE, 0.0, 1.0)
	_bag.text = _bag_text()

	if _debug.visible:
		_debug.text = _debug_text()


func _chip(i: int, key: String) -> String:
	return "[%s] %s" % [key, _shown[i]] if _prompt_alpha > 0.5 and _shown[i] != "" else ""


func _bag_text() -> String:
	var lines: PackedStringArray = []
	var tools: PackedStringArray = []
	if GameState.has_tool(&"flashlight"):
		var charge := int(round(GameState.flashlight_charge * 100.0))
		tools.append("Flashlight %d%%%s" % [charge, " (on)" if GameState.flashlight_on else ""])
	if GameState.has_tool(&"hammer"):
		tools.append("Hammer")
	if not tools.is_empty():
		var prefix := "[Q] " if GameState.has_tool(&"flashlight") else ""
		lines.append(prefix + "  ·  ".join(tools))
	var bag := {}
	for s in GameState.bag.stacks:
		bag[s["id"]] = bag.get(s["id"], 0) + s["count"]
	var used := GameState.bag.stacks.size()
	var contents := Items.describe(bag) if used > 0 else "empty"
	lines.append("Bag %d/%d: %s" % [used, GameState.bag.slots, contents])
	if GameState.is_home() and not GameState.stash.is_empty():
		var home := {}
		for s in GameState.stash.stacks:
			home[s["id"]] = home.get(s["id"], 0) + s["count"]
		lines.append("At home: " + Items.describe(home))
	return "\n".join(lines)


func _debug_text() -> String:
	if player == null:
		return "FPS %d" % Engine.get_frames_per_second()
	var p := player.global_position
	var target := player.detector.current
	return "FPS %d\npos (%.2f, %.2f, %.2f)\ntarget %s\nstate %s\nphase %s  seed %d" % [
		Engine.get_frames_per_second(), p.x, p.y, p.z,
		target.interaction_name if target else "-",
		PlayerController.State.keys()[player.state],
		GameState.phase, GameState.run_seed,
	]
