class_name LightSwitch
extends Interactable
## Wall rocker switch for a CeilingLamp. The rocker visibly flips, it clicks,
## and the lamp fades.

@export var lamp: CeilingLamp
@export var is_on := true

const ON_ANGLE := -0.3
const OFF_ANGLE := 0.3

@onready var _rocker: Node3D = $RockerPivot


func _ready() -> void:
	super()
	add_to_group(&"persistent")
	_rocker.rotation.x = ON_ANGLE if is_on else OFF_ANGLE
	if lamp:
		lamp.set_on(is_on, 0.0)


func get_state() -> Dictionary:
	return {"is_on": is_on}


func set_state(state: Dictionary) -> void:
	is_on = state.get("is_on", is_on)
	_rocker.rotation.x = ON_ANGLE if is_on else OFF_ANGLE
	if lamp:
		lamp.set_on(is_on, 0.0)


func get_prompt() -> String:
	return "Turn Light Off" if is_on else "Turn Light On"


func _on_interact(_player: Node3D) -> String:
	is_on = not is_on
	create_tween().tween_property(_rocker, "rotation:x", ON_ANGLE if is_on else OFF_ANGLE, 0.08) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	play_sound(&"SfxClick")
	if lamp:
		lamp.set_on(is_on)
	return "Light on" if is_on else "Light off"
