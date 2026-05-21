class_name SimpleGridAnimationResolver
extends GridAnimationResolver

func resolve(anim_spec: GridSpecAnimation, layer_data: GridLayerData, animation_name: StringName) -> OptionalStringName:
	var resolved_animation_name := OptionalStringName.new()
	
	resolved_animation_name.set_value(animation_name)
	
	return resolved_animation_name
