class_name Items
## Every item the player can find. Equipment (tools) is kept for good once
## found and takes no bag space; everything else goes in the bag in stacks.

const DEFS := {
	&"plank": {"name": "Plank", "stack": 2},
	&"battery": {"name": "Battery", "stack": 3},
	&"flashlight": {"name": "Flashlight", "equipment": true},
	&"hammer": {"name": "Hammer", "equipment": true},
}


static func display_name(id: StringName) -> String:
	return DEFS[id]["name"] if DEFS.has(id) else String(id)


static func stack_size(id: StringName) -> int:
	return DEFS[id].get("stack", 1) if DEFS.has(id) else 1


static func is_equipment(id: StringName) -> bool:
	return DEFS.has(id) and DEFS[id].get("equipment", false)


## "Plank x2, Battery" style list for status lines.
static func describe(counts: Dictionary) -> String:
	var parts: PackedStringArray = []
	for id in counts:
		var n: int = counts[id]
		parts.append(display_name(id) if n == 1 else "%s x%d" % [display_name(id), n])
	return ", ".join(parts)
