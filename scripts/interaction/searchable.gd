class_name Searchable
extends Interactable
## A drawer, cupboard or box to rummage through (hold E). What it holds is set
## by the place's content, and what is found stays found. If the bag is full
## the rest stays inside for later ("Take Items").

## item id -> count still inside.
@export var contents: Dictionary[StringName, int] = {}
@export var search_time := 1.8
## Optional part that opens when searched (a drawer or a cupboard door).
@export var moving_part: Node3D
## Where the moving part ends up, relative to where it starts.
@export var open_offset := Vector3.ZERO
@export var open_rotation_deg := Vector3.ZERO
## Shown instead of "Nothing useful." when it turns out empty.
@export var empty_text := ""

var searched := false
var _part_rest := Transform3D.IDENTITY


func _ready() -> void:
	super()
	add_to_group(&"persistent")
	if moving_part:
		_part_rest = moving_part.transform


func get_prompt() -> String:
	if not searched:
		return "Search %s" % interaction_name
	return "Take Items"


func get_hold_time() -> float:
	return 0.0 if searched else search_time


func can_interact() -> bool:
	return not searched or _has_items()


## Rummaging is a little noisy.
func on_hold_tick(_player: Node3D, _mode: StringName, _delta: float) -> void:
	var sound := get_node_or_null(^"SfxSearch") as AudioStreamPlayer3D
	if sound and not sound.playing:
		sound.play()
		GameState.noise(global_position, 0.1)


func _on_interact(_player: Node3D) -> String:
	var first := not searched
	searched = true
	if first:
		_open(true)
	var found := {}
	var left_behind := false
	for id in contents.keys():
		var got := GameState.give(id, contents[id])
		if got > 0:
			found[id] = got
			contents[id] -= got
		if contents[id] > 0:
			left_behind = true
		else:
			contents.erase(id)
	if not found.is_empty():
		play_sound(&"SfxFound")
		var text := "Found: " + Items.describe(found)
		return text + (" (bag full)" if left_behind else "")
	if left_behind:
		return "My bag is full."
	return empty_text if empty_text != "" else "Nothing useful."


func get_state() -> Dictionary:
	return {"searched": searched, "contents": contents.duplicate()}


func set_state(state: Dictionary) -> void:
	searched = state.get("searched", false)
	contents.assign(state.get("contents", contents))
	if searched:
		_open(false)


func _has_items() -> bool:
	for id in contents:
		if contents[id] > 0:
			return true
	return false


func _open(animate: bool) -> void:
	if moving_part == null:
		return
	var target := _part_rest
	target.origin += open_offset
	target.basis = Basis.from_euler(open_rotation_deg * (PI / 180.0)) * _part_rest.basis
	if not animate:
		moving_part.transform = target
		return
	create_tween().tween_property(moving_part, "transform", target, 0.35) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
