class_name Interactable
extends Node3D
## Something the player can use with E.
##
## Subclasses override get_prompt() and _on_interact(). The player finds the
## best one through InteractionDetector, steps to get_stand_position() when the
## object needs room to swing, reaches toward get_interaction_position(), then
## calls interact() at the moment the hand arrives.

## Emitted after a successful interaction with a short status line.
signal interacted(message: String)

## Used for debug output and the default prompt.
@export var interaction_name := "Object"
## Horizontal distance (m) from the player at which the prompt appears.
@export var interaction_range := 1.4
## How the player's arm moves: &"press" (button, switch) or &"pull" (handle).
@export var reach_style: StringName = &"press"
## Where the hand goes. Falls back to this node's origin.
@export var interaction_point: Node3D


func _ready() -> void:
	add_to_group(&"interactable")


func get_prompt() -> String:
	return "Use %s" % interaction_name


func get_interaction_position() -> Vector3:
	return interaction_point.global_position if interaction_point else global_position


## Where the player should stand before reaching, or null to use it in place.
func get_stand_position(_player_position: Vector3) -> Variant:
	return null


func can_interact() -> bool:
	return true


func interact(player: Node3D) -> void:
	var message := _on_interact(player)
	if message != "":
		interacted.emit(message)


func _on_interact(_player: Node3D) -> String:
	return ""


## Seconds E has to be held (0 = a press is enough), e.g. searching a drawer.
func get_hold_time() -> float:
	return 0.0


## R: using something from the bag on this object, e.g. nailing a plank.
## An empty string means nothing applies.
func get_item_prompt() -> String:
	return ""


func get_item_hold_time() -> float:
	return 0.0


func use_item(player: Node3D) -> void:
	var message := _on_use_item(player)
	if message != "":
		interacted.emit(message)


func _on_use_item(_player: Node3D) -> String:
	return ""


## Checked when an action (&"use" or &"item") is about to start; a non-empty
## reason cancels it and is shown to the player ("Too dark to see the nails").
func get_block_reason(_mode: StringName) -> String:
	return ""


## Called every physics frame while the player holds the key for `mode`.
func on_hold_tick(_player: Node3D, _mode: StringName, _delta: float) -> void:
	pass


## Optional second action on the same object (F), e.g. the door's peephole.
## An empty string means there is none.
func get_secondary_prompt() -> String:
	return ""


## Where to stand for the second action, or null to use it in place.
func get_secondary_stand_position(_player_position: Vector3) -> Variant:
	return null


func secondary_interact(_player: Node3D) -> void:
	pass


## Whether this object takes `item` (a Carryable) out of the player's hands.
func accepts(_item: Interactable) -> bool:
	return false


func get_accept_prompt(item: Interactable) -> String:
	return "Put %s Here" % item.interaction_name


func receive(item: Interactable, player: Node3D) -> void:
	var message := _on_receive(item, player)
	if message != "":
		interacted.emit(message)


func _on_receive(_item: Interactable, _player: Node3D) -> String:
	return ""


## Plays an optional AudioStreamPlayer3D child, with a little pitch variety.
func play_sound(node_name: StringName) -> void:
	var sound := get_node_or_null(NodePath(node_name)) as AudioStreamPlayer3D
	if sound and sound.stream:
		sound.pitch_scale = randf_range(0.95, 1.05)
		sound.play()


## True when a body of `body_radius` at `rel` (x, z relative to a hinge, in the
## object's local space) would be hit by a door swinging from `closed_angle`
## (atan2(z, x) of the closed panel) through a pivot rotation of `open_rotation`.
static func swing_contains(rel: Vector2, closed_angle: float, open_rotation: float,
		radius: float, body_radius: float) -> bool:
	var d := rel.length()
	if d > radius + body_radius:
		return false
	if d < body_radius:
		return true
	# A positive rotation about Y moves a direction's atan2(z, x) angle negatively.
	var sweep := -open_rotation
	var theta := wrapf(atan2(rel.y, rel.x) - closed_angle, -PI, PI)
	var margin := asin(clampf(body_radius / d, 0.0, 1.0))
	return theta > minf(0.0, sweep) - margin and theta < maxf(0.0, sweep) + margin
