extends Node2D

# === CONFIGURACIÓN DEL MUNDO ===
@export var spawn_radius: float = 480.0      # Radio donde spawean las luciérnagas
@export var destruction_radius: float = 600.0  # Radio donde se destruyen las luciérnagas
@export var spawn_interval: float = 1.0
@export var max_spawn_per_tick: int = 5
@export var max_fireflies_alive: int = 100

# === VARIABLES INTERNAS ===
var firefly_scene: PackedScene = preload("res://scenes/actors/Firefly.tscn")
var collected_count: int = 0
var current_fireflies: int = 0

func _ready() -> void:
	randomize()
	# Conectar todos los atractores actuales
	for attractor in get_tree().get_nodes_in_group("Attractors"):
		attractor.fireflies_collected.connect(_on_attractor_collected)

	if has_node("SpawnTimer"):
		$SpawnTimer.wait_time = spawn_interval
		$SpawnTimer.timeout.connect(_on_spawn_tick)
		$SpawnTimer.start()

func _on_spawn_tick() -> void:
	var attractors: int = get_tree().get_nodes_in_group("Attractors").size()
	if attractors <= 0:
		return
	
	# No spawear si ya hay demasiadas luciérnagas
	if current_fireflies >= max_fireflies_alive:
		return
	
	var spawn_count: int = clamp(attractors, 1, max_spawn_per_tick)
	# Asegurar que no excedamos el límite
	spawn_count = min(spawn_count, max_fireflies_alive - current_fireflies)
	
	for i in range(spawn_count):
		_spawn_firefly()

func _spawn_firefly() -> void:
	var f := firefly_scene.instantiate()
	add_child(f)
	f.world_center = global_position
	f.spawn_radius = spawn_radius
	f.destruction_radius = destruction_radius
	f.global_position = _random_point_on_spawn_border()
	
	# Asignar tipo y rareza aleatoriamente
	_assign_random_type(f)
	
	# Conectar señales
	f.collected.connect(_on_firefly_collected)
	f.destroyed.connect(_on_firefly_destroyed)
	
	current_fireflies += 1

func _assign_random_type(firefly: Node) -> void:
	var rand_value = randf()
	
	if rand_value < 0.70:  # 70% común
		firefly.set_firefly_data("basic", 1, "common")
	elif rand_value < 0.90:  # 20% poco común
		firefly.set_firefly_data("special", 3, "uncommon")
	elif rand_value < 0.98:  # 8% raro
		firefly.set_firefly_data("rare", 8, "rare")
	else:  # 2% legendario
		firefly.set_firefly_data("legendary", 20, "legendary")

func _random_point_on_spawn_border() -> Vector2:
	var angle := randf() * TAU
	return global_position + Vector2.RIGHT.rotated(angle) * spawn_radius

func _on_firefly_collected() -> void:
	collected_count += 1
	current_fireflies -= 1
	if has_node("HUD/CollectedLabel"):
		$HUD/CollectedLabel.text = "Collected: %d" % collected_count

func _on_firefly_destroyed() -> void:
	current_fireflies -= 1

# Helper for debug scripts to query world radius without relying on reflection
func get_world_radius_value() -> float:
	return spawn_radius

func _on_attractor_collected(amount: int) -> void:
	collected_count += amount
	if has_node("HUD/CollectedLabel"):
		$HUD/CollectedLabel.text = "Collected: %d" % collected_count
