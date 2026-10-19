class_name Items
## Every item the player can find. Equipment (tools) is kept for good once
## found and takes no bag space; everything else goes in the bag in stacks.

const DEFS := {
	&"plank": {"name": "Plank", "stack": 2},
	&"battery": {"name": "Battery", "stack": 3},
	&"flashlight": {"name": "Flashlight", "equipment": true},
	&"hammer": {"name": "Hammer", "equipment": true},
}


## Adds a content item (a key and the like) at runtime; same shape as DEFS.
## Kept on GameState: a static var would pin this script in memory at exit.
static func register(id: StringName, def: Dictionary) -> void:
	GameState.extra_items[id] = def


static func display_name(id: StringName) -> String:
	return _def(id).get("name", String(id))


static func stack_size(id: StringName) -> int:
	return _def(id).get("stack", 1)


static func is_equipment(id: StringName) -> bool:
	return _def(id).get("equipment", false)


static func _def(id: StringName) -> Dictionary:
	return DEFS.get(id, GameState.extra_items.get(id, {}))


## "Plank x2, Battery" style list for status lines.
static func describe(counts: Dictionary) -> String:
	var parts: PackedStringArray = []
	for id in counts:
		var n: int = counts[id]
		parts.append(display_name(id) if n == 1 else "%s x%d" % [display_name(id), n])
	return ", ".join(parts)
