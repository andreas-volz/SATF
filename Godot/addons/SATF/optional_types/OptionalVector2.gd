class_name OptionalVector2
extends Resource

@export var _has_value: bool = false
@export var _value: Vector2 = Vector2.ZERO

func set_value(v: Vector2) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value = Vector2.ZERO

func get_or(default: Vector2 = Vector2.ZERO) -> Vector2:
	return _value if _has_value else default

func has_value() -> bool:
	return _has_value
