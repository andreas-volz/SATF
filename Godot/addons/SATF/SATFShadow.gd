class_name SATFShadow
extends PointLight2D

func _ready() -> void:
	energy = 2.0
	blend_mode = Light2D.BLEND_MODE_SUB
