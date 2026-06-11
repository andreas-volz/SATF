class_name GridSpecData
extends RefCounted

## -----------------------------
## Internal data
## -----------------------------
var _fps: float
var _sprite_size: Vector2i
var _origin: Vector2
var _animations: Dictionary      # (animation_name: String)->{GridSpecAnimation}

## -----------------------------
## Public API
## -----------------------------

## Initialize from JSON dictionary
func _init(dict_data: Dictionary = {}) -> void:
	if dict_data:
		from_dict(dict_data)

## Parse (JSON) Dictionary and populate internal structures
func from_dict(dict_data: Dictionary) -> void:
	_parse_globals(dict_data)
	
	if dict_data.has("animations"):
		var animations_dict: Dictionary = dict_data["animations"]
		_parse_animations(animations_dict)

func load_from_path(path: String):
	var grid_spec_dict: Dictionary = JsonVFS.json_from_file(path)
	from_dict(grid_spec_dict)

## Return all animation names
func get_animation_names() -> Array:
	return _animations.keys()

## Return GridSpecAnimation for the given animation name
func get_animation(name: String) -> GridSpecAnimation:
	return _animations.get(name)

## Check if an animation exists by name
func has_animation(name: String) -> bool:
	return _animations.has(name)

## -----------------------------
## Internal / Helper Functions
## -----------------------------

## Parse only the global fallbacks data
func _parse_globals(globals_dict: Dictionary) -> void:
	# Parse fps with fallback and validation
	# This does automatic repair/default an invalid fps entry.
	_fps = SATFUtils.variant_to_float(globals_dict.get("fps", -1.0))
	if _fps <= 0.0:
		push_warning("Global has no valid fps. Falling back to 1.0")
		_fps = 1.0
		
	_sprite_size = SATFUtils.dict_to_vec2i(globals_dict.get("sprite_size", -Vector2i.ONE))
	if _sprite_size.x <= 0 or _sprite_size.y <= 0:
		push_warning("sprite_size invalid, using fallback (32x32)")
		_sprite_size = Vector2i(32, 32)
	
	_origin = SATFUtils.dict_to_vec2(globals_dict.get("origin", {}))

## Parse animations from JSON into GridSpecAnimation instances
func _parse_animations(animations_dict: Dictionary) -> void:
	for animation_name in animations_dict:
		var anim_dict: Dictionary = animations_dict[animation_name]
		var grid_anim_spec := GridSpecAnimation.new(self, anim_dict)
		_animations[animation_name] = grid_anim_spec

	# set inherit link
	for animation: GridSpecAnimation in _animations.values():
		if animation.inherits_from.has_value():
			if _animations.has(animation.inherits_from.get_or()):
				var inherit_animation: GridSpecAnimation = _animations[animation.inherits_from.get_or()]
				animation._inherit_link = inherit_animation
			else:
				push_warning("inheritance animation not found: ", animation.inherits_from.get_or())
