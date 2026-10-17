extends Node
## Scripted walk-through of the Room 01 acceptance checklist.
##
## Logic checks only (no window):
##     godot --headless --path . res://tests/acceptance_test.tscn
## Windowed, which also saves screenshots to tests/screens/:
##     godot --path . res://tests/acceptance_test.tscn
## The exit code is the number of failed checks.

const ROOM := preload("res://scenes/room/room_01.tscn")
## Interior plus the one-step doorway nook.
const INSIDE := AABB(Vector3(-4.3, -0.5, -3.0), Vector3(8.3, 3.0, 6.0))

var room: Node3D
var player: PlayerController
var hud: Hud
var cabinet: InteractiveCabinet
var door: InteractiveDoor
var light_switch: LightSwitch
var lamp: CeilingLamp
var radio: InteractiveRadio
var rig: Node3D

var _checks := 0
var _failures := 0
var _shots := false
var _shot_dir := ""


func _ready() -> void:
	_shots = DisplayServer.get_name() != "headless"
	_shot_dir = ProjectSettings.globalize_path("res://tests/screens")
	if _shots:
		DirAccess.make_dir_recursive_absolute(_shot_dir)
	# This test covers the room itself: no night, a frozen afternoon clock.
	GameState.new_run(1234)
	GameState.clock_running = false
	room = ROOM.instantiate()
	room.get_node("NightDirector").enabled = false
	add_child(room)
	player = room.get_node("Player")
	hud = room.get_node("Hud")
	cabinet = room.get_node("Cabinet")
	door = room.get_node("Door")
	light_switch = room.get_node("LightSwitch")
	lamp = room.get_node("CeilingLamp")
	radio = room.get_node("Radio")
	rig = room.get_node("CameraRig")
	# The bare cabinet: open, look inside, close (its contents are tested elsewhere).
	cabinet.contents.clear()
	player.scripted = true
	# Keyboard presses on the test window must not steer the run.
	player.set_process_unhandled_input(false)
	_run.call_deferred()


func _run() -> void:
	await _frames(30)
	await _shot("01_spawn")
	_check(INSIDE.has_point(player.global_position), "1. player spawns inside the room")

	await _test_movement()
	await _test_bed_blocks()
	await _test_cabinet()
	await _test_door()
	await _test_light()
	await _test_radio()
	await _test_containment()
	await _test_debug_toggle()

	print("\n%d/%d checks passed" % [_checks - _failures, _checks])
	get_tree().quit(_failures)


# ------------------------------------------------------------------ steps

func _test_movement() -> void:
	var start := player.global_position
	var max_step := 0.0
	var max_cam_jump := 0.0
	var max_cam_offset := 0.0
	var max_hip := 0.0
	var prev_cam := rig.global_position
	var prev_pos := player.global_position
	player.scripted_direction = Vector3(1, 0, -1).normalized()
	for i in 50:
		await get_tree().physics_frame
		max_step = maxf(max_step, player.global_position.distance_to(prev_pos))
		prev_pos = player.global_position
		max_cam_jump = maxf(max_cam_jump, rig.global_position.distance_to(prev_cam))
		prev_cam = rig.global_position
		var offset := player.global_position - rig.global_position
		max_cam_offset = maxf(max_cam_offset, Vector2(offset.x, offset.z).length())
		max_hip = maxf(max_hip, absf(player.get_node("Visual/Hips/HipL").rotation.x))
		if i == 35:
			await _shot("02_walking", 2.6, player.global_position + Vector3(0, 0.9, 0))
			# The close-up stalls rendering; don't count the catch-up as a jump.
			prev_pos = player.global_position
			prev_cam = rig.global_position
	player.scripted_direction = Vector3.ZERO
	var moved := start.distance_to(player.global_position)
	_check(moved > 1.0, "2. player walks (moved %.2f m)" % moved)
	_check(max_step < 0.06, "2. movement is smooth (largest step %.3f m/frame)" % max_step)
	_check(max_hip > 0.2, "2. legs swing while walking (%.2f rad)" % max_hip)
	_check(max_cam_jump < 0.06, "3. camera follows without snapping (largest jump %.3f m)" % max_cam_jump)
	_check(max_cam_offset > 0.3, "3. player is not pinned to screen centre (offset up to %.2f m)" % max_cam_offset)
	await _frames(40)
	var hip := absf(player.get_node("Visual/Hips/HipL").rotation.x)
	_check(hip < 0.05, "2. legs settle when standing still (%.3f rad)" % hip)


func _test_bed_blocks() -> void:
	await _walk_to(Vector3(-0.5, 0, 0.4))
	await _walk_dir(Vector3.LEFT, 2.5)
	var x := player.global_position.x
	_check(x > -1.75, "4. bed blocks the player (stopped at x=%.2f, bed foot at -1.92)" % x)


func _test_cabinet() -> void:
	await _walk_path([Vector3(1.5, 0, -0.6), Vector3(3.05, 0, -1.75)])
	await _nudge_toward(cabinet.get_interaction_position())
	await _use("Open Cabinet", "6-8. cabinet")
	await _wait(0.6)
	var angle := rad_to_deg(cabinet.get_node("DoorPivot").rotation.y)
	_check(cabinet.is_open and absf(angle - cabinet.open_angle_deg) < 1.0,
			"9. cabinet door rotated on its hinge (%.1f deg)" % angle)
	_check(cabinet.get_node("Contents/FirstAid").is_visible_in_tree(), "10. cabinet has items inside")
	await _shot("03_cabinet_open", 3.0, cabinet.global_position + Vector3(0, 0.9, 0.3))
	await _use("Close Cabinet", "11. cabinet")
	await _wait(0.6)
	angle = rad_to_deg(cabinet.get_node("DoorPivot").rotation.y)
	_check(not cabinet.is_open and absf(angle) < 0.5, "12. cabinet closed smoothly (%.1f deg)" % angle)


func _test_door() -> void:
	var shape: CollisionShape3D = door.get_node("DoorPivot/DoorBody/CollisionShape3D")
	await _walk_path([Vector3(2.0, 0, -1.2), Vector3(-1.5, 0, -1.3), Vector3(-3.2, 0, -2.05)])
	await _nudge_toward(door.get_interaction_position())
	await _use("Open Door", "13-15. door")
	await _wait(0.7)
	var angle := rad_to_deg(door.get_node("DoorPivot").rotation.y)
	_check(door.is_open and absf(angle - door.open_angle_deg) < 1.0, "16. door rotated on its hinge (%.1f deg)" % angle)
	_check(shape.disabled, "17. open door no longer blocks")
	await _shot("04_door_open", 3.4, door.global_position + Vector3(0.5, 1.0, 0))
	await _walk_to(Vector3(-4.2, 0, -2.43), 3.0)
	var x := player.global_position.x
	_check(x < -4.05, "17. player can step into the open doorway (x=%.2f)" % x)

	await _walk_to(Vector3(-3.3, 0, -2.1))
	await _nudge_toward(door.get_interaction_position())
	await _use("Close Door", "17. door")
	await _wait(0.8)
	_check(not door.is_open and not shape.disabled, "17. closed door blocks again")
	await _walk_to(Vector3(-3.4, 0, -2.43))
	await _walk_dir(Vector3.LEFT, 1.5)
	x = player.global_position.x
	_check(x > -3.8, "17. player cannot pass the closed door (x=%.2f)" % x)


func _test_light() -> void:
	var moon: SpotLight3D = room.get_node("WindowLight")
	await _walk_to(Vector3(-3.3, 0, -1.4))
	await _nudge_toward(light_switch.get_interaction_position())
	var fading := [0]
	var count_fading := func() -> void:
		var e := lamp.get_light_energy()
		if e > 0.05 and e < lamp.light_energy - 0.05:
			fading[0] += 1
	await _use("Turn Light Off", "18-20. light switch", count_fading)
	await _wait(0.5)
	_check(fading[0] >= 5, "21. warm light fades rather than snapping (%d in-between frames)" % fading[0])
	_check(lamp.get_light_energy() < 0.01, "22. room light is off")
	_check(moon.visible and moon.light_energy > 1.0, "23. window light remains")
	await _shot("05_light_off")
	await _use("Turn Light On", "24. light switch")
	await _wait(0.6)
	_check(absf(lamp.get_light_energy() - lamp.light_energy) < 0.01, "24. warm light back on")
	await _shot("06_light_on")


func _test_radio() -> void:
	await _walk_path([Vector3(-1.5, 0, -1.3), Vector3(1.05, 0, -1.6), Vector3(1.05, 0, -1.95)])
	await _nudge_toward(radio.get_interaction_position())
	await _use("Turn Radio On", "26-27. radio")
	await _wait(0.5)
	_check(radio.is_on and radio.get_led_energy() > 4.0, "28. radio indicator is lit")
	_check(radio.get_node("Music").playing, "29. radio plays music")
	await _shot("07_radio_on", 2.2, radio.global_position + Vector3(0, 0.2, 0.3))
	await _use("Turn Radio Off", "30. radio")
	await _wait(0.5)
	_check(not radio.is_on and radio.get_led_energy() < 0.1, "31. radio is off")


func _test_containment() -> void:
	var escaped := false
	for i in 8:
		var a := TAU * i / 8.0
		await _walk_to(Vector3(0.5, 0, 0.6), 4.0)
		player.scripted_direction = Vector3(cos(a), 0, sin(a))
		for f in 200:
			await get_tree().physics_frame
			if not INSIDE.has_point(player.global_position):
				escaped = true
		player.scripted_direction = Vector3.ZERO
	_check(not escaped, "player cannot leave the room")
	await _shot("08_end")


func _test_debug_toggle() -> void:
	var debug: Label = hud.get_node("Debug")
	_check(not debug.visible, "26. debug overlay is off by default")
	for i in 2:
		var press := InputEventAction.new()
		press.action = &"toggle_debug"
		press.pressed = true
		get_viewport().push_input(press)
		await get_tree().process_frame
		await get_tree().process_frame
		if i == 0:
			_check(debug.visible and debug.text.begins_with("FPS"), "26. F3 shows FPS / position / target")
	_check(not debug.visible, "26. F3 hides it again")


# ------------------------------------------------------------------ helpers

## Uses the current target and checks the turn / pause / reach sequence.
## `each_frame` is called every physics frame while the player is busy.
func _use(prompt: String, label: String, each_frame := Callable()) -> void:
	await _frames(4)
	var target := player.detector.current
	var got := target.get_prompt() if target else "<none>"
	_check(got == prompt, "%s: prompt '%s' (got '%s')" % [label, prompt, got])
	_check(hud.get_prompt_text() == "[E] " + prompt, "%s: HUD shows '[E] %s' (got '%s')" % [label, prompt, hud.get_prompt_text()])
	if not player.try_interact():
		_check(false, "%s: interaction started" % label)
		return
	var max_reach := 0.0
	var max_speed := 0.0
	var reach_started := false
	while player.is_busy():
		await get_tree().physics_frame
		if each_frame.is_valid():
			each_frame.call()
		max_reach = maxf(max_reach, player.animator.reach_weight)
		if player.state == PlayerController.State.INTERACT:
			reach_started = true
			max_speed = maxf(max_speed, Vector2(player.velocity.x, player.velocity.z).length())
	var to := target.get_interaction_position() - player.global_position
	var facing := player.get_facing_direction().dot(Vector3(to.x, 0, to.z).normalized())
	_check(reach_started and max_reach > 0.9, "%s: player reaches toward it (%.2f)" % [label, max_reach])
	_check(facing > 0.9, "%s: player turned toward it (dot %.2f)" % [label, facing])
	_check(max_speed < 0.6, "%s: player paused while using it (%.2f m/s)" % [label, max_speed])


func _walk_path(points: Array[Vector3]) -> void:
	for p in points:
		await _walk_to(p)


func _walk_to(target: Vector3, timeout := 6.0) -> void:
	var t := 0.0
	while t < timeout:
		var to := target - player.global_position
		to.y = 0.0
		if to.length() < 0.1:
			break
		player.scripted_direction = to.normalized() * clampf(to.length() / 0.4, 0.3, 1.0)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	player.scripted_direction = Vector3.ZERO
	await _frames(20)


func _walk_dir(dir: Vector3, sec: float) -> void:
	player.scripted_direction = dir.normalized()
	await _wait(sec)
	player.scripted_direction = Vector3.ZERO
	await _frames(15)


func _nudge_toward(point: Vector3) -> void:
	var to := point - player.global_position
	player.scripted_direction = Vector3(to.x, 0, to.z).normalized() * 0.35
	await _frames(8)
	player.scripted_direction = Vector3.ZERO
	await _frames(20)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _wait(sec: float) -> void:
	await get_tree().create_timer(sec, true, true).timeout


## Saves a screenshot when running windowed. With `zoom` > 0 it also saves a
## close-up centred on `focus`, then restores the camera.
func _shot(name: String, zoom := 0.0, focus := Vector3.ZERO) -> void:
	if not _shots:
		return
	await RenderingServer.frame_post_draw
	_save(name)
	if zoom <= 0.0:
		return
	var camera: Camera3D = rig.get_node("Pitch/Camera3D")
	var size := camera.size
	var pos := rig.global_position
	rig.set_physics_process(false)
	camera.size = zoom
	rig.global_position = focus
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	_save(name + "_close")
	camera.size = size
	rig.global_position = pos
	rig.set_physics_process(true)


func _save(name: String) -> void:
	var path := _shot_dir.path_join(name + ".png")
	get_viewport().get_texture().get_image().save_png(path)
	print("      screenshot ", path)


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + what)
