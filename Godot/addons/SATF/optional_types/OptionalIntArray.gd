class_name OptionalIntArray
extends Resource

@export var _has_value: bool = false
@export var _value: Array[int] = []

func set_value(v: Array[int]) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value.clear()

func get_or(default: Array[int] = []) -> Array[int]:
	return _value if _has_value else default

func has_value() -> bool:
	return _has_value
