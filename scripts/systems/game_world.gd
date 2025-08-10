extends Node2D

@export var world_radius: float = 480.0
@export var spawn_interval: float = 1.0
@export var max_spawn_per_tick: int = 5

var firefly_scene: PackedScene = preload("res://scenes/actors/Firefly.tscn")
var collected_count: int = 0

func _ready() -> void:
	randomize()
	if has_node("SpawnTimer"):
		$SpawnTimer.wait_time = spawn_interval
		$SpawnTimer.timeout.connect(_on_spawn_tick)
		$SpawnTimer.start()

func _on_spawn_tick() -> void:
	var attractors: int = get_tree().get_nodes_in_group("Attractors").size()
	if attractors <= 0:
		return
	var spawn_count: int = clamp(attractors, 1, max_spawn_per_tick)
	for i in range(spawn_count):
		_spawn_firefly()

func _spawn_firefly() -> void:
	var f := firefly_scene.instantiate()
	add_child(f)
	f.world_center = global_position
	f.world_radius = world_radius
	f.global_position = _random_point_on_border()
	f.collected.connect(_on_firefly_collected)

func _random_point_on_border() -> Vector2:
	var angle := randf() * TAU
	return global_position + Vector2.RIGHT.rotated(angle) * world_radius

func _on_firefly_collected() -> void:
	collected_count += 1
	if has_node("HUD/CollectedLabel"):
		$HUD/CollectedLabel.text = "Collected: %d" % collected_count

# Helper for debug scripts to query world radius without relying on reflection
func _get_world_radius_value() -> float:
	return world_radius
