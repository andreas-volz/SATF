class_name GridLayerCollection
extends RefCounted

## -----------------------------
## Internal properties
## -----------------------------

# Ordered list of layers (defines processing / render order)
var _layers: Array[GridLayerData] = []

# Optional lookup: layer_id -> index in _layers
# key: StringName, value: int
var _layer_lookup: Dictionary = {}

## -----------------------------
## Public API
## -----------------------------

func get_layers() -> Array[GridLayerData]:
	return _layers


func get_layer_count() -> int:
	return _layers.size()


func get_layer_by_index(index: int) -> GridLayerData:
	if index < 0 or index >= _layers.size():
		return null
	return _layers[index]

func get_layer_index_from_id(layer_id: StringName) -> int:
	var index: int = _layer_lookup.keys().find(layer_id)
	return index

func get_layer(layer_id: StringName) -> GridLayerData:
	if not _layer_lookup.has(layer_id):
		return null
	return _layers[_layer_lookup[layer_id]]


func has_layer(layer_id: StringName) -> bool:
	return _layer_lookup.has(layer_id)


## -----------------------------
## Mutating API (Editor / Build)
## -----------------------------

func add_layer(layer: GridLayerData) -> void:
	_layers.append(layer)
	_rebuild_lookup()


func remove_layer(layer_id: StringName) -> void:
	if not _layer_lookup.has(layer_id):
		return
	var index: int = _layer_lookup[layer_id]
	_layers.remove_at(index)
	_rebuild_lookup()

func clear() -> void:
	_layers.clear()
	_layer_lookup.clear()

func from_dict(dict: Dictionary) -> bool:
	var result: bool = true
	
	if dict.has("layers"):
		var layers = dict["layers"]
		clear()
		if layers is Array:
			for layer_dict in layers:
				var layer := GridLayerData.new()
				layer.from_dict(layer_dict)
				add_layer(layer)
	
	return result

func to_dict() -> Dictionary:
	var layer_collection_dict: Dictionary = {}
	
	layer_collection_dict["layers"] = []
	for layer: GridLayerData in _layers:
		layer_collection_dict["layers"].append(layer.to_dict())
	
	return layer_collection_dict


## -----------------------------
## Internal helpers
## -----------------------------
# TODO: this code in not yet tested and verified!
func _rebuild_lookup() -> void:
	_layer_lookup.clear()
	for i in _layers.size():
		var layer := _layers[i]
		if layer.layer_id.has_value():
			_layer_lookup[layer.layer_id.get_or()] = i

# TODO: this code in not yet tested and verified!
#func _validate_unique_ids() -> bool:
	#var seen: Dictionary = {}
	#for layer: GridLayerData in _layers:
		#if not layer.layer_id.has_value():
			#continue
		#var id := layer.layer_id.get_or()
		#if seen.has(id):
			#return false
		#seen[id] = true
	#return true
