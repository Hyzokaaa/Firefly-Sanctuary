extends Area2D
class_name Firefly

signal collected
signal destroyed  # Nueva señal

@export var roam_speed: float = 70.0
@export var seek_speed: float = 95.0
@export var jitter: float = 0.2 # radians per second of random wobble
@export var vision_radius: float = 200.0
@export var world_center: Vector2 = Vector2.ZERO
@export var spawn_radius: float = 480.0      # Radio donde spawean
@export var destruction_radius: float = 600.0  # Radio donde se destruyen

# === TIPOS Y VALORES ===
@export var firefly_type: String = "basic"   # Tipo de luciérnaga
@export var dust_value: int = 1              # Valor en polvo lumínico
@export var rarity: String = "common"        # common, uncommon, rare, legendary

var _velocity: Vector2 = Vector2.ZERO
var _target: Node2D = null
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	input_pickable = true
	_rng.randomize()
	if _velocity == Vector2.ZERO:
		var angle := _rng.randf_range(0.0, TAU)
		_velocity = Vector2.RIGHT.rotated(angle) * roam_speed

func _physics_process(delta: float) -> void:
	_update_target()
	if is_instance_valid(_target):
		_seek_target(delta)
		_attempt_capture()
	else:
		_wander(delta)
	
	# Apply movement
	global_position += _velocity * delta
	
	# Despawn when reaching destruction radius
	var distance_from_center := global_position.distance_to(world_center)
	if distance_from_center >= destruction_radius:
		emit_signal("destroyed")
		queue_free()

func _update_target() -> void:
	var nearest: Node2D = null
	var best_score: float = 0.0
	
	for n in get_tree().get_nodes_in_group("Attractors"):
		if n is Node2D:
			# Skip full attractors if they expose capacity API
			if n.has_method("can_accept") and not n.can_accept():
				continue
			if n.has_method("is_full") and n.is_full():
				continue
			
			var d2: float = (n.global_position - global_position).length_squared()
			var attraction_radius_squared = vision_radius * vision_radius
			
			# Si el atractor tiene su propio radio, usarlo
			if n.has_method("get_attraction_radius"):
				var attractor_radius = n.get_attraction_radius()
				attraction_radius_squared = attractor_radius * attractor_radius
			
			if d2 <= attraction_radius_squared:
				# Si hay múltiples atractores, elegir el de mayor fuerza
				var attraction_force = 1.0
				if n.has_method("get_attraction_force"):
					attraction_force = n.get_attraction_force()
				
				# Usar una métrica que combine distancia y fuerza
				var score = attraction_force / max(sqrt(d2), 1.0)  # Fuerza dividida por distancia
				
				if score > best_score:
					best_score = score
					nearest = n
	
	_target = nearest

func _wander(delta: float) -> void:
	# Movimiento puramente errático - sin bias hacia el centro
	var rot_jitter := _rng.randf_range(-jitter, jitter) * delta
	_velocity = _velocity.rotated(rot_jitter)
	_velocity = _velocity.limit_length(roam_speed)
	
	# Opcional: cambio de dirección ocasional para más variedad
	if _rng.randf() < 0.01:  # 1% de probabilidad por frame
		var random_angle := _rng.randf_range(0.0, TAU)
		_velocity = Vector2.RIGHT.rotated(random_angle) * roam_speed

func _seek_target(_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var desired := (_target.global_position - global_position).normalized()
	var wobble := Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU)) * 0.15
	desired = (desired * 0.9 + wobble * 0.1).normalized()
	var desired_vel := desired * seek_speed
	_velocity = _velocity.lerp(desired_vel, 0.08)

func _attempt_capture() -> void:
	if not is_instance_valid(_target):
		return
	var target_pos := _target.global_position
	var r: float = 24.0
	if _target.has_method("get_capture_radius"):
		r = float(_target.get_capture_radius())
	if global_position.distance_to(target_pos) <= r:
		# Try to register with the attractor
		if _target.has_method("add_one") and _target.has_method("can_accept"):
			if _target.can_accept() and _target.add_one():
				queue_free()
				return
		# If cannot accept, drop target so we can pick another next frame
		if _target.has_method("is_full") and _target.is_full():
			_target = null

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		emit_signal("collected")
		print("Caputraste tanke")
		queue_free()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("collected")
		queue_free()

# === UTILIDADES ===
func get_firefly_type() -> String:
	return firefly_type

func get_dust_value() -> int:
	return dust_value

func get_rarity() -> String:
	return rarity

func set_firefly_data(type: String, value: int, rarity_level: String) -> void:
	firefly_type = type
	dust_value = value
	rarity = rarity_level
	_update_visual_by_rarity()

func _update_visual_by_rarity() -> void:
	# Cambiar color según rareza
	match rarity:
		"common":
			modulate = Color.WHITE
		"uncommon":
			modulate = Color.CYAN
		"rare":
			modulate = Color.YELLOW
		"legendary":
			modulate = Color.MAGENTA
