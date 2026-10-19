extends Node
## Mouse-only play in the home room, driven by real mouse events at the
## screen positions of things:
##   click the floor behind the bed -> walks around it and gets there
##   click the cabinet              -> walks over and opens it
##   right-click menu on the door   -> peephole; a click closes it
##   click the door, then the floor -> opens it; the walkable area grows
##     godot --headless --path . res://tests/pointer_test.tscn

const ROOM := preload("res://scenes/room/room_01.tscn")

var room: Node3D
var player: PlayerController
var pointer: Pointer
var camera: Camera3D
var _checks := 0
var _failures := 0


func _ready() -> void:
	Journal.use_memory_only()
	GameState.new_run(77)
	GameState.clock_running = false
	room = ROOM.instantiate()
	room.get_node("NightDirector").enabled = false
	add_child(room)
	player = room.get_node("Player")
	pointer = room.get_node("Hud/Pointer")
	camera = room.get_node("CameraRig/Pitch/Camera3D")
	player.set_process_unhandled_input(false)
	_run.call_deferred()


func _run() -> void:
	await _frames(20)

	var goal := Vector3(-3.3, 0, 1.7)
	await _click_at(camera.unproject_position(goal))
	_check(player.is_walking(), "a click on the floor starts a walk")
	await _until(func() -> bool: return not player.is_walking(), 10.0)
	var off := Vector2(player.global_position.x - goal.x, player.global_position.z - goal.z).length()
	_check(off < 0.3, "walked around the bed to the clicked spot (%.2f m off)" % off)

	var cabinet: InteractiveCabinet = room.get_node("Cabinet")
	cabinet.contents.clear()
	await _hover(cabinet)
	_check(pointer.hover == cabinet, "hovering the cabinet picks it")
	await _shot("p1_hover_cabinet")
	await _click_at(camera.unproject_position(cabinet.get_interaction_position()))
	await _until(func() -> bool: return cabinet.is_open, 10.0)
	_check(cabinet.is_open, "a click on the cabinet walks over and opens it")

	var door: InteractiveDoor = room.get_node("Door")
	await _until(func() -> bool: return not player.is_busy(), 3.0)
	await _hover(door)
	pointer._right(player)
	await _frames(2)
	var labels := []
	for i in pointer._menu.item_count:
		labels.append(pointer._menu.get_item_text(i))
	_check("Look Through Peephole" in labels, "right-click on the door lists %s" % [labels])
	await _shot("p2_right_click_menu")
	pointer._menu.hide()
	pointer._on_menu(labels.find("Look Through Peephole"))
	await _until(func() -> bool: return player.state == PlayerController.State.FOCUS, 10.0)
	_check(player.state == PlayerController.State.FOCUS, "the menu choice walks to the door and looks")
	await _click_at(Vector2(100, 100))
	await _frames(5)
	_check(player.state != PlayerController.State.FOCUS, "a click stops looking")

	await _hover(door)
	await _click_at(camera.unproject_position(door.get_interaction_position()))
	await _until(func() -> bool: return door.is_open, 10.0)
	_check(door.is_open, "a click on the door opens it")
	await _frames(20)
	var map := player.get_world_3d().navigation_map
	var path := NavigationServer3D.map_get_path(map, player.global_position, Vector3(-4.3, 0, -2.43), true)
	var end := path[path.size() - 1] if path.size() > 0 else player.global_position
	_check(end.x < -4.1, "with the door open a path leads out through the doorway (ends x=%.2f)" % end.x)

	# Free the room and let the audio server drop its playbacks before quitting.
	room.queue_free()
	await get_tree().create_timer(0.3).timeout
	print("\n%d/%d checks passed" % [_checks - _failures, _checks])
	get_tree().quit(_failures)


func _hover(target: Interactable) -> void:
	_move_mouse(camera.unproject_position(target.get_interaction_position()))
	await _frames(3)


## `at` is in viewport coordinates; input events arrive in window coordinates
## (the headless window is tiny, so the stretch transform matters).
func _move_mouse(at: Vector2) -> void:
	at = get_viewport().get_final_transform() * at
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	Input.parse_input_event(motion)


func _click_at(at: Vector2) -> void:
	_move_mouse(at)
	await _frames(3)
	at = get_viewport().get_final_transform() * at
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = at
		click.global_position = at
		Input.parse_input_event(click)
		await _frames(1)


func _until(condition: Callable, timeout: float) -> void:
	var start := Time.get_ticks_msec()
	while not condition.call() and (Time.get_ticks_msec() - start) / 1000.0 < timeout:
		await get_tree().physics_frame


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


## Saves a screenshot to tests/screens/ when running windowed.
func _shot(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var dir := ProjectSettings.globalize_path("res://tests/screens")
	DirAccess.make_dir_recursive_absolute(dir)
	get_viewport().get_texture().get_image().save_png(dir.path_join(name + ".png"))


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + what)
