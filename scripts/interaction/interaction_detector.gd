class_name InteractionDetector
extends Node3D
## Picks the single best interactable around the player.
##
## Closest wins; objects off to the side or behind cost extra, objects behind a
## wall are skipped, and the current target gets a small bonus so the prompt
## doesn't flicker between two neighbours.

signal target_changed(target: Interactable)

## Extra "distance" (m) charged for an object directly behind the player.
@export var facing_weight := 0.5
## Bonus (m) for keeping the current target.
@export var keep_bonus := 0.15
## Height of the line-of-sight ray above the player's feet.
@export var eye_height := 1.2

var current: Interactable = null


## `carrying` is the item in the player's hands, if any: then only objects
## that accept it are offered.
func update_target(origin: Vector3, forward: Vector3, exclude: Array[RID],
		carrying: Interactable = null) -> void:
	var best: Interactable = null
	var best_score := INF
	for node in get_tree().get_nodes_in_group(&"interactable"):
		var it := node as Interactable
		if it == null or not it.is_available():
			continue
		if carrying and not it.accepts(carrying):
			continue
		var to := it.get_interaction_position() - origin
		to.y = 0.0
		var dist := to.length()
		if dist > it.interaction_range:
			continue
		var facing := forward.dot(to / maxf(dist, 0.001))
		var score := dist + facing_weight * (1.0 - facing)
		if it == current:
			score -= keep_bonus
		if score < best_score and has_line_of_sight(origin, it, exclude):
			best = it
			best_score = score
	if best != current:
		current = best
		target_changed.emit(current)


## True if `it` can be seen (and reached for) from a player standing at `origin`.
func has_line_of_sight(origin: Vector3, it: Interactable, exclude: Array[RID]) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
			origin + Vector3.UP * eye_height, it.get_interaction_position())
	query.exclude = exclude
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	# Hitting the object's own collider (a closed door, say) still counts as seen.
	var collider := hit.collider as Node
	return collider != null and it.is_ancestor_of(collider)
