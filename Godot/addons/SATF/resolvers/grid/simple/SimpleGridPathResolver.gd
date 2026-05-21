class_name SimpleGridPathResolver
extends GridPathResolver

func resolve(layer_data: GridLayerData, animation_name: StringName) -> OptionalString:
	var resolved_path: String
	
	resolved_path = layer_data.asset_reference.base_path + "/" + animation_name
	if layer_data.asset_reference.variant.has_value():
		resolved_path += "/" + layer_data.asset_reference.variant.get_or()
	
	var optional_resolved_path := OptionalString.new()
	optional_resolved_path.set_value(resolved_path)
	return optional_resolved_path
	
