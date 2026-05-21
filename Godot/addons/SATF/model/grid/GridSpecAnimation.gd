class_name GridSpecAnimation
extends RefCounted

## -----------------------------
## Public properties
## -----------------------------
var fps: float : get = get_fps, set = set_fps
var sprite_size: Vector2i : get = get_sprite_size, set = set_sprite_size
var origin: Vector2 : get = get_origin, set = set_origin
var frames: OptionalIntArray : get = get_frames, set = set_frames
var inherits_from: OptionalStringName : get = get_inherits_from, set = set_inherits_from
var directions: OptionalDictionary: get = get_directions, set = set_directions
var row: OptionalInt: get = get_row, set = set_row
var frame_mode: OptionalStringName: get = get_frame_mode, set = set_frame_mode

## -----------------------------
## Internal data
## -----------------------------
var _parent: GridSpecData = null
var _inherit_link: GridSpecAnimation = null # optional inheritance link

var _fps := OptionalFloat.new()
var _frames := OptionalIntArray.new()
var _sprite_size := OptionalVector2i.new()
var _origin := OptionalVector2.new()
var _inherits_from := OptionalStringName.new()
var _row := OptionalInt.new()
var _directions := OptionalDictionary.new() # key(String), value(GridSpecAnimationDirection)
var _frame_mode := OptionalStringName.new()

enum FrameMode {
	LINEAR,
	MAPPED
}

## -----------------------------
## Constructor / Initialization
## -----------------------------

## Initialize a single animation spec from (JSON) Dictionary
func _init(parent_param: GridSpecData, dict_data: Dictionary = {}) -> void:
	_parent = parent_param
	if _parent == null:
		push_error("Parent of GridSpecAnimation shouldn't be null!")
	elif dict_data:
		parse_dict(dict_data)

func parse_dict(dict_data: Dictionary) -> void:
	if dict_data.has("inherits_from"):
		var inherits_from := SATFUtils.variant_to_string(dict_data.get("inherits_from"))
		_inherits_from.set_value(inherits_from)
	
	if dict_data.has("frames"):
		var frames_int := SATFUtils.array_to_array_int(dict_data.get("frames", []))
		_frames.set_value(frames_int)
	
	if dict_data.has("row"):
		var row_int := SATFUtils.variant_to_int(dict_data.get("row", 0))
		_row.set_value(row_int)
		
	if dict_data.has("fps"):
		var fps_f := SATFUtils.variant_to_float(dict_data.get("fps", -1.0))
		if fps_f <= 0.0:
			push_warning("Global has no valid fps. Falling back to 1.0")
			fps_f = 1.0
		_fps.set_value(fps_f)
		
	if dict_data.has("sprite_size"):
		var sprite_size_opt = SATFUtils.dict_to_vec2i(dict_data.get("sprite_size", -Vector2i.ONE))
		if sprite_size_opt.x <= 0 or sprite_size_opt.y <= 0:
			push_warning("sprite_size invalid, using fallback (32x32)")
			sprite_size_opt = Vector2i(32, 32)
		_sprite_size.set_value(sprite_size_opt)
	
	if dict_data.has("origin"):
		var origin_opt = SATFUtils.dict_to_vec2(dict_data.get("origin", {}))
		_origin.set_value(origin_opt)
		
	if dict_data.has("frame_mode"):
		_frame_mode.set_value(SATFUtils.variant_to_string(dict_data.get("frame_mode")))
	
	if dict_data.has("directions"):
		for direction_name in dict_data["directions"]:
			var direction_dict: Dictionary = dict_data["directions"][direction_name]
			var anim_spec_direction := GridSpecAnimationDirection.new(self, direction_dict)
			_directions.set_entry(direction_name, anim_spec_direction)
	
## -----------------------------
## Public API
## -----------------------------

## Return frames-per-second for this sprite set
func get_fps() -> float:
	return _fps.get_or(_parent._fps)

func set_fps(value: float) -> void:
	_fps.set_value(value)

func get_sprite_size() -> Vector2i:
	if _sprite_size.has_value():
		return _sprite_size.get_or()
	
	if _inherit_link != null:
		return _inherit_link.sprite_size
	
	return _parent._sprite_size

func set_sprite_size(value: Vector2i) -> void:
	_sprite_size.set_value(value)

func get_origin() -> Vector2:
	return _origin.get_or(_parent._origin)

func set_origin(value: Vector2) -> void:
	_origin.set_value(value)

func get_inherits_from() -> OptionalStringName:
	return _inherits_from
	
func set_inherits_from(inherits_from_param: OptionalStringName):
	_inherits_from = inherits_from_param

func get_frames() -> OptionalIntArray:
	if _frames.has_value():
		return _frames
	
	if _inherit_link != null:
		return _inherit_link.frames
	
	# return frames in case it has no value
	return _frames

func set_frames(value: OptionalIntArray):
	_frames = value

func get_directions() -> OptionalDictionary:
	if _directions.has_value():
		return _directions
	
	# return custom_frames in case it has no value
	return _directions
	
func set_directions(value: OptionalDictionary):
	_directions = value

func get_row() -> OptionalInt:
	return _row

func set_row(value: OptionalInt):
	_row = value

func get_frame_mode() -> OptionalStringName:
	return _frame_mode
	
func set_frame_mode(frame_mode_param: OptionalStringName):
	_frame_mode = frame_mode_param

func get_frame_mode_enum() -> FrameMode:
	match _frame_mode.get_or():
		"linear": return FrameMode.LINEAR
		"mapped", "": return FrameMode.MAPPED
		_:
			push_warning("Unknown frame_mode: %s" % _frame_mode)
			return FrameMode.MAPPED

func set_frame_mode_enum(mode: FrameMode) -> void:
	match mode:
		FrameMode.LINEAR: _frame_mode.set_value("linear")
		FrameMode.MAPPED: _frame_mode.set_value("mapped")
		_:
			push_warning("Unknown frame_mode Enum value: %s" % mode)

## -----------------------------
## Internal / Helper Functions
## -----------------------------
