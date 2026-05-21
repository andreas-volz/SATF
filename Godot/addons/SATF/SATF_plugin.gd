@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("SATFSprite", "Sprite2D", preload("runtime/sprite/node/SATFSprite.gd"), preload("icons/SATFSprite.svg"))
	add_custom_type("SATFSpriteControl", "Control", preload("ui/SATFSpriteControl.gd"), preload("icons/SATFSpriteControl.svg"))
	add_custom_type("SATFAnimationPlayer", "AnimationPlayer", preload("runtime/animation_player/SATFAnimationPlayer.gd"), preload("icons/SATFAnimationPlayer.svg"))
	add_custom_type("SATFAnimationTree", "AnimationTree", preload("runtime/animation_tree/SATFAnimationTree.gd"), preload("icons/SATFAnimationTree.svg"))
	add_custom_type("SATFAnimationResource", "Animation", preload("runtime/animation_player/SATFAnimationResource.gd"), preload("icons/SATFAnimation.svg"))
	add_custom_type("SATFAnimationNodeBlendSpace2D", "AnimationNodeBlendSpace2D", preload("runtime/animation_tree/SATFAnimationNodeBlendSpace2D.gd"), preload("icons/SATFAnimation.svg"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("SATFAnimationNodeBlendSpace2D")
	remove_custom_type("SATFAnimationResource")
	remove_custom_type("SATFAnimationTree")
	remove_custom_type("SATFAnimationPlayer")
	remove_custom_type("SATFSpriteControl")
	remove_custom_type("SATFSprite")
	remove_custom_type("SATFShadow")
	
