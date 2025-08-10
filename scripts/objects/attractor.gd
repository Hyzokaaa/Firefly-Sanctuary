extends Area2D

@export var capacity: int = 10
@export var attraction_strength: float = 1.0
@export var attraction_radius: float = 200.0  # Nueva variable - radio de atracción
@export var current_count: int = 0
@export var debug_force_full: bool = false
@export var capture_radius: float = 24.0

var _label: Label = null
var _sprite: Sprite2D = null
signal fireflies_collected(amount: int)

func _ready() -> void:
	add_to_group("Attractors")
	# Hacer clickeable para recolección manual
	input_pickable = true
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

# === NUEVOS MÉTODOS PARA FIREFLY ===
func get_attraction_radius() -> float:
	return attraction_radius

func get_attraction_force() -> float:
	return attraction_strength

# === UI ===
func _refresh_ui() -> void:
	if _label:
		_label.text = "%d/%d" % [current_count, capacity]
		_label.modulate = Color(1, 0.4, 0.4, 1) if is_full() else Color(0.8, 1, 0.8, 1)
	if _sprite:
		_sprite.modulate = Color(1, 0.6, 0.6, 1) if is_full() else Color(0.7, 0.9, 1, 1)

# === RECOLECCIÓN MANUAL ===
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_collect_fireflies()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_collect_fireflies()

func _collect_fireflies() -> void:
	if current_count > 0:
		emit_signal("fireflies_collected", current_count)
		remove_all()
		
