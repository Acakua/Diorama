class_name Pointer
extends Node
## Mouse-only play. Hovering an object highlights it and names what a click
## does; left click walks there and does it (or walks to a spot on the floor);
## right click opens a small menu of everything the object offers. A click
## while busy stops the current action or closes the peephole / note.

## Objects within this many pixels of the cursor can be picked.
const PICK_RADIUS := 34.0

@export var hud: Hud

## The object under the cursor, if any.
var hover: Interactable = null

var _menu: PopupMenu
var _menu_target: Interactable = null
var _menu_actions := []
var _ring: MeshInstance3D
var _ring_tween: Tween
## Last cursor position seen in a mouse event (viewport coordinates).
var _mouse := Vector2(-1000, -1000)


func _ready() -> void:
	_menu = PopupMenu.new()
	_menu.id_pressed.connect(_on_menu)
	add_child(_menu)


func _process(_delta: float) -> void:
	var player := hud.player if hud else null
	hover = _pick(player) if player and player.controls_enabled and not _menu.visible else null
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if hover else Input.CURSOR_ARROW)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse = (event as InputEventMouse).position


func _unhandled_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button == null or not button.pressed:
		return
	var player := hud.player
	if player == null or not player.controls_enabled:
		return
	match button.button_index:
		MOUSE_BUTTON_LEFT:
			_left(player)
			get_viewport().set_input_as_handled()
		MOUSE_BUTTON_RIGHT:
			_right(player)
			get_viewport().set_input_as_handled()


## Left click on `target` (or on the floor at `floor_point` when null). Public for tests.
func click(player: PlayerController, target: Interactable, floor_point := Vector3.INF) -> void:
	if player.state == PlayerController.State.FOCUS:
		player.end_focus()
		return
	if player.state == PlayerController.State.HOLD:
		player.cancel_action()
		return
	if target:
		var actions := player.get_actions(target)
		if not actions.is_empty():
			player.command(target, actions[0][1])
			_show_ring(target.get_interaction_position())
		return
	if floor_point != Vector3.INF:
		player.walk_to(floor_point)
		_show_ring(floor_point)


func _left(player: PlayerController) -> void:
	click(player, hover, Vector3.INF if hover else _floor_point())


func _right(player: PlayerController) -> void:
	if player.state == PlayerController.State.FOCUS:
		player.end_focus()
		return
	_menu.clear()
	_menu_actions = []
	_menu_target = hover
	if hover:
		_menu_actions = player.get_actions(hover)
	if player.carried and (hover == null or _menu_actions.is_empty()):
		_menu_actions.append(["Put Down %s" % player.carried.interaction_name, &"put_down"])
	if _menu_actions.is_empty():
		return
	for i in _menu_actions.size():
		_menu.add_item(_menu_actions[i][0], i)
	var at := _mouse
	_menu.popup(Rect2i(Vector2i(at) + Vector2i(8, 8), Vector2i.ZERO))


func _on_menu(id: int) -> void:
	var player := hud.player
	var action: Array = _menu_actions[id]
	if action[1] == &"put_down":
		player.put_down()
	elif _menu_target:
		player.command(_menu_target, action[1])
		_show_ring(_menu_target.get_interaction_position())


func _pick(player: PlayerController) -> Interactable:
	if player.camera == null:
		return null
	var mouse := _mouse
	var best: Interactable = null
	var best_d := PICK_RADIUS
	for node in get_tree().get_nodes_in_group(&"interactable"):
		var it := node as Interactable
		if it == null or not it.is_visible_in_tree() or player.get_actions(it).is_empty():
			continue
		var d := mouse.distance_to(player.camera.unproject_position(it.get_interaction_position()))
		if d < best_d:
			best = it
			best_d = d
	return best


## Where the cursor ray meets the floor plane. (Physics hits are no good here:
## the cut-away walls have tall invisible colliders.)
func _floor_point() -> Vector3:
	var camera := hud.player.camera
	var from := camera.project_ray_origin(_mouse)
	var dir := camera.project_ray_normal(_mouse)
	if absf(dir.y) < 0.001:
		return Vector3.INF
	return from + dir * (-from.y / dir.y)


func _show_ring(at: Vector3) -> void:
	if _ring == null or not is_instance_valid(_ring):
		_ring = MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.16
		torus.outer_radius = 0.2
		torus.rings = 24
		torus.ring_segments = 6
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1.0, 0.95, 0.85, 0.85)
		torus.material = mat
		_ring.mesh = torus
		_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hud.player.get_parent().add_child(_ring)
	_ring.global_position = Vector3(at.x, 0.03, at.z)
	_ring.scale = Vector3.ONE * 1.4
	_ring.transparency = 0.0
	_ring.visible = true
	if _ring_tween:
		_ring_tween.kill()
	_ring_tween = create_tween().set_parallel()
	_ring_tween.tween_property(_ring, "scale", Vector3.ONE * 0.7, 0.45).set_ease(Tween.EASE_OUT)
	_ring_tween.tween_property(_ring, "transparency", 1.0, 0.6).set_delay(0.2)
