class_name Hud
extends CanvasLayer
## Minimal HUD: a single "[E] action" prompt at the bottom with a small ring
## over the object it refers to, a short status line after each interaction,
## and an F3 debug readout that starts hidden.

@export var player: PlayerController

const STATUS_HOLD := 1.4
const STATUS_FADE := 0.5
## Prompt offsets from the bottom edge (px); it rises a little as it appears.
const PROMPT_TOP := -100.0
const PROMPT_BOTTOM := -44.0
const PROMPT_RISE := 8.0

var _prompt_alpha := 0.0
var _status_time := 0.0
var _last_action := ""

@onready var _marker: Control = $Marker
@onready var _prompt: Control = $Prompt
@onready var _action: Label = $Prompt/Box/Row/Action
@onready var _status: Label = $Status
@onready var _debug: Label = $Debug


func _ready() -> void:
	_prompt.modulate.a = 0.0
	_marker.modulate.a = 0.0
	_status.modulate.a = 0.0
	_debug.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		_debug.visible = not _debug.visible


## Text currently offered to the player, e.g. "[E] Open Cabinet", or "".
func get_prompt_text() -> String:
	return "[E] %s" % _action.text if _prompt_alpha > 0.5 else ""


func show_status(text: String) -> void:
	_status.text = text
	_status_time = STATUS_HOLD + STATUS_FADE


func _process(delta: float) -> void:
	var target: Interactable = player.detector.current if player else null
	var show := target != null and not player.is_busy()
	if show:
		var action := target.get_prompt()
		if action != _last_action:
			_last_action = action
			_action.text = action
		if player.camera:
			_marker.position = player.camera.unproject_position(target.get_interaction_position())
	_prompt_alpha = move_toward(_prompt_alpha, 1.0 if show else 0.0, delta * 7.0)
	_prompt.modulate.a = _prompt_alpha
	_marker.modulate.a = _prompt_alpha
	var rise := (1.0 - _prompt_alpha) * PROMPT_RISE
	_prompt.offset_top = PROMPT_TOP + rise
	_prompt.offset_bottom = PROMPT_BOTTOM + rise

	_status_time = maxf(0.0, _status_time - delta)
	_status.modulate.a = clampf(_status_time / STATUS_FADE, 0.0, 1.0)

	if _debug.visible:
		_debug.text = _debug_text(target)


func _debug_text(target: Interactable) -> String:
	if player == null:
		return "FPS %d" % Engine.get_frames_per_second()
	var p := player.global_position
	return "FPS %d\npos (%.2f, %.2f, %.2f)\ntarget %s\nstate %s" % [
		Engine.get_frames_per_second(), p.x, p.y, p.z,
		target.interaction_name if target else "-",
		PlayerController.State.keys()[player.state],
	]
