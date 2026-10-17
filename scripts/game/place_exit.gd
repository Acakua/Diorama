class_name PlaceExit
extends Area3D
## A doorway out of this place. Walking into it (through the open door) takes
## the player to `target_scene`, spawning at the marker named `target_entry`.

@export_file("*.tscn") var target_scene := ""
@export var target_entry := ""


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var player := body as PlayerController
	if player == null or not player.controls_enabled or GameState.phase == &"over":
		return
	if player.carried:
		player.notice.emit("I can't take the %s out with me." % player.carried.interaction_name.to_lower())
		return
	GameState.travel(target_scene, target_entry)
