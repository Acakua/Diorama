class_name Carryable
extends Interactable
## Furniture the player can pick up, carry (slowly), put down, or hand to an
## object that accepts it, like the door taking a chair as a wedge.
## Expects a "Body" StaticBody3D child; its shapes switch off while carried.

## Item origin relative to the player's hold point.
@export var hold_offset := Vector3(0.0, -0.55, 0.0)
## Clearance box (m) checked before putting the item down.
@export var footprint := Vector3(0.48, 0.9, 0.48)
## Movement speed multiplier while carrying it.
@export var carry_speed := 0.7
## Can be wedged under a door handle.
@export var wedges_doors := false

## Who is holding it, if anyone.
var carrier: Node3D = null
## Set while another object (a door) holds it in place.
var docked := false
var _home: Node = null

@onready var _body: CollisionObject3D = $Body


func _ready() -> void:
	super()
	add_to_group(&"persistent")


func get_prompt() -> String:
	return "Pick Up %s" % interaction_name


func can_interact() -> bool:
	return carrier == null and not docked


func _on_interact(player: Node3D) -> String:
	(player as PlayerController).pick_up(self)
	return ""


## Moves the item into `holder` (the player's hold point).
func attach_to(holder: Node3D, by: Node3D) -> void:
	if _home == null:
		_home = get_parent()
	carrier = by
	_set_solid(false)
	reparent(holder, false)
	position = hold_offset
	rotation = Vector3.ZERO
	play_sound(&"SfxPickup")


## Leaves the player's hands at `xform`, under `new_parent` (its original
## parent by default), and becomes solid again.
func place_at(xform: Transform3D, new_parent: Node = null) -> void:
	carrier = null
	reparent(new_parent if new_parent else _home, false)
	global_transform = xform
	_set_solid(true)


## Returns the item to its original parent without moving it.
func release_in_place() -> void:
	docked = false
	var xform := global_transform
	reparent(_home if _home else get_parent(), false)
	global_transform = xform


func get_state() -> Dictionary:
	return {"xform": global_transform}


func set_state(state: Dictionary) -> void:
	if state.has("xform"):
		global_transform = state["xform"]


func _set_solid(on: bool) -> void:
	for shape in _body.find_children("*", "CollisionShape3D"):
		shape.set_deferred(&"disabled", not on)
