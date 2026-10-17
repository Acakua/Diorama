class_name FocusMarker
extends Control
## Small ring drawn over the object the prompt refers to, so the player can
## tell the light switch from the door handle half a metre away. While a held
## action runs it fills up as a progress ring.

@export var radius := 7.0
@export var color := Color(1.0, 0.95, 0.85)

## 0..1 progress of a held action (0 = none).
var progress := 0.0
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 1.0 + 0.12 * sin(_time * 4.0)
	draw_arc(Vector2.ZERO, radius * pulse + 1.5, 0.0, TAU, 24, Color(0, 0, 0, 0.45), 3.5, true)
	draw_arc(Vector2.ZERO, radius * pulse, 0.0, TAU, 24, color, 2.0, true)
	draw_circle(Vector2.ZERO, 2.0, color)
	if progress > 0.0:
		var r := radius + 6.0
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(0, 0, 0, 0.5), 5.0, true)
		draw_arc(Vector2.ZERO, r, -PI / 2.0, -PI / 2.0 + TAU * progress, 32, color, 3.0, true)
