class_name SATFUtils
extends RefCounted

# TODO test type_convert() if this could replace some implementations

# if ignore_null=true then ignore if an Array entry  is null, but then code the position
# this is helpful for editor property lists to save an enum value
# e.g. ["first", "second", null, "fourth"] => "first: 0, second: 1, fourth: 3"
static func array_to_string(string_array: Array, separator: String, enum_ignore_null: bool = false) -> String:
	var result_string: String = ""
	var counter = 0
	for str_element in string_array:
		if not (enum_ignore_null and str_element == null):
			result_string += str_element
			
			if enum_ignore_null:
				result_string += ":" + str(counter)
			
			if counter < string_array.size() - 1 and string_array[counter+1] != null:
				result_string += separator
		counter += 1
	return result_string

static func dict_to_vec2(d: Dictionary, default := Vector2.ZERO) -> Vector2:
	## Convert a dictionary {"x": val, "y": val} to Vector2 with basic validation
	if typeof(d) != TYPE_DICTIONARY or d.is_empty():
		return default

	var x = d.get("x", default.x)
	var y = d.get("y", default.y)

	# Only accept int or float, else fallback
	if not (x is int or x is float):
		x = default.x
	if not (y is int or y is float):
		y = default.y

	return Vector2(x, y)

static func dict_to_vec2i(d: Dictionary, default := Vector2i.ZERO) -> Vector2i:
	if typeof(d) != TYPE_DICTIONARY or d.is_empty():
		return default

	var x = d.get("x", default.x)
	var y = d.get("y", default.y)

	if not (x is int or x is float):
		x = default.x
	if not (y is int or y is float):
		y = default.y

	return Vector2i(int(x), int(y))

static func variant_to_int(v: Variant, default: int = 0) -> int:
	if v is int or v is float:
		return int(v)
	push_error("Couldn't convert to int - fallback to: ", default)
	return default
	
static func variant_to_string(v: Variant, default: String = "") -> String:
	if v is String:
		return v
	push_error("Couldn't convert to String - fallback to: ", default)
	return default
	
static func variant_to_float(v: Variant, default: float = 0.0) -> float:
	if v is int or v is float:
		return float(v)
	push_error("Couldn't convert to float - fallback to: ", default)
	return default

static func array_to_array_int(arr: Array) -> Array[int]:
	var arr_int: Array[int] = []
	if not arr is Array:
		return arr_int
	for elem in arr:
		arr_int.append(variant_to_int(elem))
	return arr_int
	
static func array_to_array_string(arr: Array) -> Array[String]:
	var arr_str: Array[String] = []
	if not arr is Array:
		return arr_str
	for elem in arr:
		arr_str.append(variant_to_string(elem))
	return arr_str


	
	
