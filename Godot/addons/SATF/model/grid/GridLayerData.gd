class_name GridLayerData
extends RefCounted

## Unique identifier for the layer.
## Used for runtime lookup, UI representation, and external control.
var layer_id := OptionalStringName.new()

## Dictionary mapping animation_name -> GridLayerAnimation
## key: String, value: GridLayerAnimation
var animations: Dictionary = {}

## Logical grouping identifier for related layers.
## TODO: document the use case for this - if needed or remove itz
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

func from_dict(dict: Dictionary) -> bool:
	var result: bool = true
	
	if dict.has("layer_id"):
		layer_id.set_value(dict["layer_id"])
		
	if dict.has("group"):
		group.set_value(dict["group"])
		
	if dict.has("z_index"):
		group.set_value(dict["z_index"])
		
	if dict.has("palette_bindings"):
		push_warning("palette_bindings to be implemented")
		
	# TODO: this might be optimized by a helper function
	# could be used also in LPCGridLayerCollectionBuilder.create_from_sheet_collection()
	if dict.has("animations"):
		var animations_dict = dict["animations"]
		if animations_dict is Dictionary:
			var new_animations := {}
			for anim_dict_name in animations_dict.keys():
				var anim_dict = animations_dict[anim_dict_name]
				var grid_animation := GridLayerAnimation.new()
				grid_animation.from_dict(anim_dict)
				new_animations[anim_dict_name] = grid_animation
			animations = new_animations
	else:
		push_warning("no 'animations' in Dictionary")
				
	if dict.has("asset_reference"):
		result = asset_reference.from_dict(dict["asset_reference"])
	else:
		push_warning("no 'asset_reference' in Dictionary")
		result =  false
	
	return result

func to_dict() -> Dictionary:
	var layer_data_dict: Dictionary = {}
	
	if layer_id.has_value():
		layer_data_dict["layer_id"] = layer_id.get_or()
	
	if group.has_value():
		layer_data_dict["group"] = group.get_or()
				
	if z_index.has_value():
		layer_data_dict["z_index"] = z_index.get_or()
		
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
	


	
