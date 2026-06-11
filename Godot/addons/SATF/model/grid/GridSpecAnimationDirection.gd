class_name GridSpecAnimationDirection
extends Node

## -----------------------------
## Public properties
## -----------------------------
var frames: OptionalIntArray : get = get_frames, set = set_frames
var row: int: get = get_row, set = set_row

## -----------------------------
## Internal data
## -----------------------------
var _parent: GridSpecAnimation = null

var _frames := OptionalIntArray.new()
var _row: int

## -----------------------------
## Constructor / Initialization
## -----------------------------

## Initialize a single animation direction spec from (JSON) Dictionary
func _init(parent_param: GridSpecAnimation, dict_data: Dictionary = {}) -> void:
	_parent = parent_param
	if _parent == null:
		push_error("Parent of GridSpecAnimation shouldn't be null!")
	elif dict_data:
		from_dict(dict_data)
		pass

func from_dict(dict_data: Dictionary) -> void:
	if dict_data.has("frames"):
		var frames_int := SATFUtils.array_to_array_int(dict_data.get("frames", []))
		_frames.set_value(frames_int)
	
	if dict_data.has("row"):
		var row_int := SATFUtils.variant_to_int(dict_data.get("row", 0))
		_row = row_int
	else:
		push_error("The parameter 'direction' needs a 'row'!")

## -----------------------------
## Public API
## -----------------------------

func get_frames() -> OptionalIntArray:
	if _frames.has_value():
		return _frames
	
	return _parent.frames

func set_frames(value: OptionalIntArray):
	_frames = value

func get_row() -> int:
	return _row

func set_row(value: int):
	_row = value
	
	
