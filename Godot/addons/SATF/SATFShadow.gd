@tool
class_name SATFShadow
extends PointLight2D

@export var texture_scale_correction: Vector2 = Vector2.ONE
var texture_scale_xy: Vector2 = Vector2.ONE

func _ready() -> void:
	energy = 2.0
	blend_mode = Light2D.BLEND_MODE_SUB

func _process(delta: float) -> void:
	if texture != null:
		# TBD: bug
		texture.width = texture_scale_xy.x * texture_scale_correction.x
		texture.height = texture_scale_xy.y * texture_scale_correction.y
