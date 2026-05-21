class_name OptionalVector2i
extends Resource

@export var _has_value: bool = false
@export var _value: Vector2i = Vector2i.ZERO

func set_value(v: Vector2i) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value = Vector2i.ZERO

func get_or(default: Vector2i = Vector2i.ZERO) -> Vector2i:
	return _value if _has_value else default

func has_value() -> bool:
	return _has_value
