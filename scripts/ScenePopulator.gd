extends Node
## Phase 3 scene bootstrapper. Populates MultiMesh stars, cloud cluster,
## and Earth mesh into their parent nodes on _ready.
##
## Why a script: the .tscn for FlightScene declares the parent nodes
## (Stars, Earth, Clouds) but the actual meshes are too verbose (2200
## stars, cloud cluster of 4 spheres, etc.) to author as text. We build
## them in code using ParticleManager static helpers, then parent them
## under the placeholder nodes the .tscn declared.

const ParticleManager = preload("res://scripts/ParticleManager.gd")

@export var stars_path: NodePath
@export var earth_path: NodePath
@export var clouds_path: NodePath


func _ready() -> void:
	_populate_stars()
	_populate_earth()
	_populate_clouds()


func _populate_stars() -> void:
	var parent := get_node_or_null(stars_path) as MultiMeshInstance3D
	if parent == null:
		return
	# Replace the empty MultiMesh with the populated one from ParticleManager.
	var fresh: MultiMeshInstance3D = ParticleManager.build_stars()
	# Copy the populated multimesh into the existing node so we keep the
	# .tscn-declared position/visibility.
	parent.multimesh = fresh.multimesh
	parent.material_override = fresh.material_override


func _populate_earth() -> void:
	var parent := get_node_or_null(earth_path) as Node3D
	if parent == null:
		return
	var mi := ParticleManager.build_earth()
	mi.name = "EarthMesh"
	parent.add_child(mi)


func _populate_clouds() -> void:
	var parent := get_node_or_null(clouds_path) as Node3D
	if parent == null:
		return
	# Scatter ~8 cloud clusters at varied positions and rotations.
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242
	for i in 8:
		var cluster := ParticleManager.build_cloud_cluster()
		cluster.name = "Cloud_%d" % i
		cluster.position = Vector3(
			rng.randf_range(-220.0, 220.0),
			rng.randf_range(180.0, 320.0),
			rng.randf_range(-220.0, -40.0)
		)
		cluster.rotation.y = rng.randf() * TAU
		var scale: float = rng.randf_range(3.5, 6.0)
		cluster.scale = Vector3(scale, scale * 0.7, scale)
		parent.add_child(cluster)
