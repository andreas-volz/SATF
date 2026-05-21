class_name OptionalFloat
extends Resource

@export var _has_value: bool = false
@export var _value: float = 0

func set_value(v: float) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value = 0

func get_or(default: float = 0.0) -> float:
	return _value if _has_value else default

func has_value() -> bool:
	return _has_value
