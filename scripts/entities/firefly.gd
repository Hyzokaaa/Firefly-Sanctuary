extends Area2D

class_name Firefly

signal collected

@export var roam_speed: float = 70.0
@export var seek_speed: float = 95.0
@export var jitter: float = 0.2 # radians per second of random wobble
@export var vision_radius: float = 200.0
@export var world_center: Vector2 = Vector2.ZERO
@export var world_radius: float = 480.0

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

	# Despawn when far outside and moving away from the center
	var away_vec := global_position - world_center
	if away_vec.length() > world_radius + 64.0 and away_vec.dot(_velocity) > 0.0:
		queue_free()

func _update_target() -> void:
	var nearest: Node2D = null
	var nearest_d2: float = INF
	for n in get_tree().get_nodes_in_group("Attractors"):
		if n is Node2D:
			# Skip full attractors if they expose capacity API
			if n.has_method("can_accept") and not n.can_accept():
				continue
			if n.has_method("is_full") and n.is_full():
				continue
			var d2: float = (n.global_position - global_position).length_squared()
			if d2 < nearest_d2 and d2 <= vision_radius * vision_radius:
				nearest_d2 = d2
				nearest = n
	_target = nearest

func _wander(delta: float) -> void:
	var rot_jitter := _rng.randf_range(-jitter, jitter) * delta
	_velocity = _velocity.rotated(rot_jitter)
	_velocity = _velocity.limit_length(roam_speed)

	# Slight bias back towards center to keep them around
	var to_center := (world_center - global_position).normalized()
	_velocity = (_velocity * 0.9 + to_center * 0.1 * roam_speed).limit_length(roam_speed)

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
		queue_free()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("collected")
		queue_free()
