extends Node
## Loads every place for a few seconds and quits; errors show up in the log.
##     godot --headless --path . res://tests/smoke_test.tscn

const PLACES := [
	"res://scenes/room/room_01.tscn",
	"res://content/places/corridor_4.tscn",
	"res://content/places/flat_4b.tscn",
	"res://content/places/flat_4c.tscn",
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Journal.use_memory_only()
	for path in PLACES:
		var place: Node = load(path).instantiate()
		add_child(place)
		for i in 30:
			await get_tree().physics_frame
		print("ok  ", path)
		place.queue_free()
		await get_tree().process_frame
	# Let the audio server drop the places' playbacks before quitting.
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
