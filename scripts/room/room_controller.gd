extends Node3D
## Wires Room 01 together: hands the player to the HUD, routes every
## interactable's status message to it, and puts the player back on the spawn
## point if they ever end up outside the room.

@export var player: PlayerController
@export var hud: Hud
@export var spawn: Marker3D
## Anything outside this box counts as "escaped" (includes the doorway nook).
@export var room_bounds := AABB(Vector3(-4.7, -1.0, -3.2), Vector3(8.9, 4.0, 6.4))


func _ready() -> void:
	hud.player = player
	for node in get_tree().get_nodes_in_group(&"interactable"):
		(node as Interactable).interacted.connect(hud.show_status)


func _physics_process(_delta: float) -> void:
	if not room_bounds.has_point(player.global_position):
		player.global_position = spawn.global_position
		player.velocity = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
