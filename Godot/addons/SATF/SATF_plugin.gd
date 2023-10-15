@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("SATFSprite", "Sprite2D", preload("SATFSprite.gd"), preload("icon.svg"))
	add_custom_type("SATFShadow", "PointLight2D", preload("SATFShadow.gd"), preload("icon.svg"))
	add_custom_type("SATFAnimationPlayer", "AnimationPlayer", preload("SATFAnimationPlayer.gd"), preload("icon.svg"))
	add_custom_type("SATFAnimationTree", "AnimationTree", preload("SATFAnimationTree.gd"), preload("icon.svg"))
	add_custom_type("SATFAnimationResource", "Animation", preload("SATFAnimationResource.gd"), preload("icon.svg"))
	add_custom_type("SATFAnimationNodeBlendSpace2D", "AnimationNodeBlendSpace2D", preload("SATFAnimationTree.gd"), preload("icon.svg"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("SATFAnimationNodeBlendSpace2D")
	remove_custom_type("SATFAnimationResource")
	remove_custom_type("SATFAnimationTree")
	remove_custom_type("SATFAnimationPlayer")
	remove_custom_type("SATFShadow")
	remove_custom_type("SATFSprite")
