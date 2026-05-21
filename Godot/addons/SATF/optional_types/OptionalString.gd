@tool
class_name OptionalString
extends Resource

@export var _has_value: bool = false
@export var _value: String = ""

func set_value(v: String) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value = ""

func get_or(default: String = "") -> String:
	return _value if _has_value else default

func has_value() -> bool:
	return _has_value
