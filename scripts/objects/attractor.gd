extends Node2D

@export var capacity: int = 10
@export var attraction_strength: float = 1.0
@export var current_count: int = 0
@export var debug_force_full: bool = false
@export var capture_radius: float = 24.0

var _label: Label = null
var _sprite: Sprite2D = null

func _ready() -> void:
	add_to_group("Attractors")
	if has_node("CapacityLabel"):
		_label = $CapacityLabel
	if has_node("Sprite2D"):
		_sprite = $Sprite2D
	_refresh_ui()

func is_full() -> bool:
	if debug_force_full:
		return true
	return current_count >= capacity

func can_accept() -> bool:
	return not is_full()

func add_one() -> bool:
	if can_accept():
		current_count += 1
		_refresh_ui()
		return true
	return false

func remove_all() -> void:
	current_count = 0
	_refresh_ui()

func get_capture_radius() -> float:
	return capture_radius

func _refresh_ui() -> void:
	if _label:
		_label.text = "%d/%d" % [current_count, capacity]
		_label.modulate = Color(1, 0.4, 0.4, 1) if is_full() else Color(0.8, 1, 0.8, 1)
	if _sprite:
		_sprite.modulate = Color(1, 0.6, 0.6, 1) if is_full() else Color(0.7, 0.9, 1, 1)
