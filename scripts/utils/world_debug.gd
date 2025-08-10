@tool
extends Node2D

@export var show_debug: bool = true
@export var color_border: Color = Color(0.3, 0.8, 1.0, 0.6)
@export var color_center: Color = Color(1, 1, 1, 0.8)
@export var border_width: float = 2.0
@export var points: int = 128
@export var use_parent_world_radius: bool = true
@export var world_radius_override: float = 480.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not show_debug:
		return
	var radius := _get_world_radius()
	# Draw border arc
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, max(points, 8), color_border, border_width)
	# Draw center cross
	var s := 8.0
	draw_line(Vector2(-s, 0), Vector2(s, 0), color_center, 1.0)
	draw_line(Vector2(0, -s), Vector2(0, s), color_center, 1.0)

func _get_world_radius() -> float:
	if use_parent_world_radius and get_parent():
		var parent := get_parent()
		# Preferred: explicit helper on parent
		if parent.has_method("_get_world_radius"):
			return float(parent._get_world_radius())
		# Fallback: introspect parent's properties
		var has_prop := false
		for p in parent.get_property_list():
			if typeof(p) == TYPE_DICTIONARY and p.has("name") and p["name"] == "world_radius":
				has_prop = true
				break
		if has_prop:
			var r = parent.get("world_radius")
			if typeof(r) == TYPE_FLOAT or typeof(r) == TYPE_INT:
				return float(r)
	return world_radius_override
