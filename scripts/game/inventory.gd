class_name Inventory
extends RefCounted
## A bag of item stacks. `slots` < 0 means unlimited (the home stash).

signal changed

var slots := 3
## Array of {"id": StringName, "count": int}, one entry per occupied slot.
var stacks: Array[Dictionary] = []


func _init(slot_count := 3) -> void:
	slots = slot_count


func count(id: StringName) -> int:
	var total := 0
	for s in stacks:
		if s["id"] == id:
			total += s["count"]
	return total


## Adds up to `amount`, topping up existing stacks first. Returns how many fit.
func add(id: StringName, amount: int) -> int:
	var left := amount
	var limit := Items.stack_size(id)
	for s in stacks:
		if left == 0:
			break
		if s["id"] == id and s["count"] < limit:
			var put: int = mini(left, limit - s["count"])
			s["count"] += put
			left -= put
	while left > 0 and (slots < 0 or stacks.size() < slots):
		var put := mini(left, limit)
		stacks.append({"id": id, "count": put})
		left -= put
	if left != amount:
		changed.emit()
	return amount - left


## Removes up to `amount`. Returns how many were removed.
func remove(id: StringName, amount: int) -> int:
	var left := amount
	for i in range(stacks.size() - 1, -1, -1):
		if left == 0:
			break
		if stacks[i]["id"] == id:
			var take: int = mini(left, stacks[i]["count"])
			stacks[i]["count"] -= take
			left -= take
			if stacks[i]["count"] == 0:
				stacks.remove_at(i)
	if left != amount:
		changed.emit()
	return amount - left


## Moves everything into `other`; whatever doesn't fit stays. Returns what moved.
func move_all_to(other: Inventory) -> Dictionary:
	var moved := {}
	for s in stacks:
		var n := other.add(s["id"], s["count"])
		s["count"] -= n
		if n > 0:
			moved[s["id"]] = moved.get(s["id"], 0) + n
	stacks.assign(stacks.filter(func(stack: Dictionary) -> bool: return stack["count"] > 0))
	if not moved.is_empty():
		changed.emit()
	return moved


func is_empty() -> bool:
	return stacks.is_empty()
