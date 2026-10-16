extends Node
## Frame-time check for Room 01: loads the room, lets it settle, then prints
## average / worst FPS over a few seconds with the lamp on and off.
##     godot --path . res://tests/fps_probe.tscn

const ROOM := preload("res://scenes/room/room_01.tscn")


func _ready() -> void:
	var room := ROOM.instantiate()
	add_child(room)
	_run.call_deferred(room)


func _run(room: Node) -> void:
	await get_tree().create_timer(2.0).timeout
	print("lamp on:  ", await _measure(4.0))
	room.get_node("CeilingLamp").set_on(false, 0.0)
	await get_tree().create_timer(0.5).timeout
	print("lamp off: ", await _measure(3.0))
	get_tree().quit()


func _measure(seconds: float) -> String:
	var frames := 0
	var worst := 0.0
	var start := Time.get_ticks_usec()
	var last := start
	while Time.get_ticks_usec() - start < seconds * 1e6:
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		worst = maxf(worst, (now - last) / 1000.0)
		last = now
		frames += 1
	var avg_ms := (Time.get_ticks_usec() - start) / 1000.0 / frames
	return "avg %.1f fps (%.2f ms), worst frame %.1f ms" % [1000.0 / avg_ms, avg_ms, worst]
