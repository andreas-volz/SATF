class_name GridLayerData
extends RefCounted

## Unique identifier for the layer.
## Used for runtime lookup, UI representation, and external control.
var layer_id := OptionalStringName.new()

## Dictionary mapping animation_name -> GridLayerAnimation
## key: String, value: GridLayerAnimation
var animations: Dictionary

## Target slot in the final sprite.
## The slot enforces that only one asset can be active per slot.
## Assigning a new asset to the same slot replaces the previous one.
## Example: "head" ensures only one head asset is active at a time.
var slot := OptionalStringName.new()

## Logical grouping identifier for related layers.
## Multiple layers sharing the same group can be controlled together.
## Example: a sword may consist of several layers; using the same group
## allows toggling visibility for all layers of the sword at once.
var group := OptionalStringName.new()

## Rendering order of the layer.
## Higher values are rendered on top of lower ones.
var z_index := OptionalInt.new()

## References an asset image by base_path and optional variant.
## This is later in the pipeline used to build a path
var asset_reference := AssetReference.new()

var palette_bindings: Array[PaletteBinding] = []

func get_animation_names() -> Array:
	return animations.keys()
	
func has_animation(animation_name: String) -> bool:
	return animations.has(animation_name)
	
func get_animation(animation_name: String) -> GridLayerAnimation:
	return animations.get(animation_name)

func to_dict() -> Dictionary:
	var layer_data_dict: Dictionary = {}
	
	if layer_id.has_value():
		layer_data_dict["layer_id"] = layer_id.get_or()
		
	if slot.has_value():
		layer_data_dict["slot"] = slot.get_or()
		
	if z_index.has_value():
		layer_data_dict["z_index"] = z_index.get_or()
		
	if group.has_value():
		layer_data_dict["group"] = group.get_or()
		
	if not palette_bindings.is_empty():
		layer_data_dict["palette_bindings"] = []
		
	# TODO implement writing to json
	# TODO create a reference palette section in the layer data beside "animations"
	#for palette_bindings: PaletteBinding in palette_bindings:
		#layer_data_dict["palette_bindings"].append(palette_bindings.to_dict())
	
	layer_data_dict["animations"] = {}
	for animation_name in animations:
		var grid_anim_layer: GridLayerAnimation = animations[animation_name]
		layer_data_dict["animations"][animation_name] = grid_anim_layer.to_dict()
		
	layer_data_dict["asset_reference"] = asset_reference.to_dict()
	
	return layer_data_dict
	

func parse_dict(dict_data: Dictionary):
	push_warning("Not yet implemented")
	
