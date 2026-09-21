extends RefCounted
class_name AssetLoader
## Lightweight loader for Blender `.glb` exports. Falls back to the
## primitive mesh baked into a `RocketPartData` when the `.glb` isn't
## present, so the prototype stays fully playable without an artist
## having exported anything yet.
##
## Phase 3 strategy:
##   1. Author the asset in Blender (see docs/blender/).
##   2. Drop the .glb at e.g. `assets/models/nose_classic.glb`.
##   3. Set `RocketPartData.glb_path = "res://assets/models/nose_classic.glb"`.
##   4. The next time the game runs, the builder uses it.

const _cache: Dictionary = {}


## Load the mesh for a part. Returns a Mesh resource (primitive or .glb)
## or null if neither is available.
static func load_part_mesh(data) -> Mesh:
	if data == null:
		return null
	# Try .glb first.
	if data.glb_path and data.glb_path.strip_edges() != "":
		var cached = _cache.get(data.glb_path)
		if cached:
			return cached
		if ResourceLoader.exists(data.glb_path):
			var packed = load(data.glb_path)
			if packed is PackedScene:
				var instance: Node = (packed as PackedScene).instantiate()
				if instance:
					# Cache the first MeshInstance3D we find.
					var mesh := _find_first_mesh(instance)
					if mesh:
						_cache[data.glb_path] = mesh
						instance.queue_free()
						return mesh
			elif packed is Mesh:
				_cache[data.glb_path] = packed
				return packed
	# Fallback to primitive.
	if data.primitive_mesh:
		return data.primitive_mesh
	return null


## Recursively find the first MeshInstance3D under a root and return its mesh.
## Returns null if no mesh found.
static func _find_first_mesh(root: Node) -> Mesh:
	if root is MeshInstance3D:
		var mi: MeshInstance3D = root
		if mi.mesh:
			return mi.mesh
	for child in root.get_children():
		var found := _find_first_mesh(child)
		if found:
			return found
	return null


## Load a non-rocket scene by res:// path (for moon, cloud, tower).
static func load_scene(path: String) -> Node:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var packed := load(path)
		if packed is PackedScene:
			return (packed as PackedScene).instantiate()
	return null
