class_name Place
extends Node3D
## Root of every diorama place (home, the corridor, a neighbour's flat).
##
## Puts the player at the entry they came through, restores what the place
## looked like when they last left and saves it again on the way out, wires
## the HUD, and handles the evening: at home the night begins; anywhere else
## the player has a few seconds to get back. Content places extend this and
## roll their loot in _first_visit().

@export var player: PlayerController
@export var hud: Hud
@export var overlay: NightOverlay
@export var camera_rig: IsoCamera
## Spawn point for a new run, or when the entry marker isn't found.
@export var spawn: Marker3D
## Home only: runs the night.
@export var night: NightDirector
## Played once when darkness catches the player away from home.
@export var stranded_sound: AudioStreamPlayer
## Anything outside this box counts as escaped and is put back at the spawn.
@export var room_bounds := AABB(Vector3(-50, -5, -50), Vector3(100, 20, 100))


func _ready() -> void:
	GameState.current_place = self
	hud.player = player
	player.notice.connect(hud.show_status)
	GameState.notice.connect(hud.show_status)
	for node in get_tree().get_nodes_in_group(&"interactable"):
		(node as Interactable).interacted.connect(hud.show_status)
	if GameState.places.has(scene_file_path):
		_restore(GameState.places[scene_file_path])
	else:
		_first_visit()
	_spawn_player()
	GameState.phase_changed.connect(_on_phase)
	if is_home():
		_arrive_home()
	_on_phase(GameState.phase)


func is_home() -> bool:
	return scene_file_path == GameState.HOME


## Records every "persistent" node's state for the next visit.
func save_state() -> void:
	var states := {}
	for node in get_tree().get_nodes_in_group(&"persistent"):
		if is_ancestor_of(node):
			states[str(get_path_to(node))] = node.get_state()
	GameState.places[scene_file_path] = states


## Override to roll this place's contents the first time it is visited.
func _first_visit() -> void:
	pass


func _restore(states: Dictionary) -> void:
	for path in states:
		var node := get_node_or_null(NodePath(path))
		if node and node.has_method(&"set_state"):
			node.set_state(states[path])


func _spawn_player() -> void:
	var marker := spawn
	if GameState.entry != "":
		var named := find_child(GameState.entry, true, false) as Node3D
		if named:
			marker = named
	if marker:
		player.global_position = marker.global_position
		player.facing_yaw = marker.global_rotation.y
		player.animator.rotation.y = player.facing_yaw
	if camera_rig:
		camera_rig.snap()


func _arrive_home() -> void:
	var moved := GameState.unpack()
	if not moved.is_empty():
		hud.show_status("Unpacked: " + Items.describe(moved))
	if GameState.phase == &"stranded":
		GameState.set_phase(&"night")
	if GameState.entry == "" and GameState.hour < GameState.DAY_START + 0.05:
		overlay.show_objective("Find supplies before dark (20:00)")


func _on_phase(phase: StringName) -> void:
	match phase:
		&"night":
			if night:
				night.begin(GameState.stranded_time > 0.0)
		&"stranded":
			if not is_home():
				overlay.show_thought("It's getting dark... I have to get home. Now.", 5.0)
				if stranded_sound:
					stranded_sound.play()


func _physics_process(_delta: float) -> void:
	if not room_bounds.has_point(player.global_position) and spawn:
		player.global_position = spawn.global_position
		player.velocity = Vector3.ZERO
	if GameState.phase == &"stranded" and not is_home() \
			and GameState.stranded_time > GameState.STRANDED_LIMIT:
		GameState.set_phase(&"over")
		player.controls_enabled = false
		overlay.show_end(false, "It found you in the hallway at %s." % GameState.clock_text())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
