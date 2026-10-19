class_name Place
extends Node3D
## Root of every diorama place (home, the corridor, a neighbour's flat).
##
## Puts the player at the entry they came through, restores what the place
## looked like when they last left and saves it again on the way out, wires
## the HUD, and handles the evening: at home the night begins; anywhere else
## the player has a few seconds to get back. It also keeps the walkable area
## (navigation mesh) up to date for click-to-move. Content places extend this
## and roll their loot in _first_visit().

@export var player: PlayerController
@export var hud: Hud
@export var overlay: NightOverlay
@export var camera_rig: IsoCamera
## Spawn point for a new run, or when the entry marker isn't found.
@export var spawn: Marker3D
## Home only: runs the night.
@export var night: NightDirector
## Walkable area for click-to-move, baked from this place's static colliders.
@export var navigation: NavigationRegion3D
## Played once when darkness catches the player away from home.
@export var stranded_sound: AudioStreamPlayer
## Written in the journal the first time the player gets here.
@export var journal_id: StringName = &""
@export var journal_title := ""
@export_multiline var journal_text := ""
## Anything outside this box counts as escaped and is put back at the spawn.
@export var room_bounds := AABB(Vector3(-50, -5, -50), Vector3(100, 20, 100))

@export_group("Sound")
## What the floor sounds like underfoot (a Footsteps set: wood, carpet).
@export var floor_surface: StringName = &"wood"
## The room's echo on the "World" bus: how big it sounds, how soft its
## surfaces are (curtains, beds and rugs damp it) and how much of it is heard.
@export_range(0.0, 1.0) var reverb_size := 0.3
@export_range(0.0, 1.0) var reverb_damping := 0.6
@export_range(0.0, 1.0) var reverb_wet := 0.12

var _nav_dirty := 0


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
	_apply_acoustics()
	if journal_id != &"":
		Journal.learn(journal_id, &"places", journal_title, journal_text)
	if navigation:
		add_to_group(&"nav_source")
		navigation.bake_navigation_mesh(false)
		GameState.navigation_changed.connect(_on_navigation_changed)
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


func _apply_acoustics() -> void:
	var bus := AudioServer.get_bus_index(&"World")
	if bus >= 0 and AudioServer.get_bus_effect_count(bus) > 0:
		var reverb := AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
		if reverb:
			reverb.room_size = reverb_size
			reverb.damping = reverb_damping
			reverb.wet = reverb_wet
	var steps := player.get_node_or_null(^"Footsteps") as Footsteps
	if steps:
		steps.set_surface(floor_surface)


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
	# Rebake a couple of frames after a change, once deferred collider edits landed.
	if _nav_dirty > 0 and navigation and not navigation.is_baking():
		_nav_dirty -= 1
		if _nav_dirty == 0:
			navigation.bake_navigation_mesh(true)
	if not room_bounds.has_point(player.global_position) and spawn:
		player.global_position = spawn.global_position
		player.velocity = Vector3.ZERO
	if GameState.phase == &"stranded" and not is_home() \
			and GameState.stranded_time > GameState.STRANDED_LIMIT:
		GameState.set_phase(&"over")
		player.controls_enabled = false
		overlay.show_end(false, "It found you in the hallway at %s." % GameState.clock_text())


func _on_navigation_changed() -> void:
	_nav_dirty = 2


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
