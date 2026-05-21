@tool
class_name SATFAnimationNodeBlendSpace2D
extends AnimationNodeBlendSpace2D

func get_resource(_root_node: AnimationRootNode) -> SATFAnimationNodeBlendSpace2D:
	return self

func create_animation_blend_point(animation_name : String, direction_name : String, direction_vector: Vector2):
	var animation_node := AnimationNodeAnimation.new()
		
	var animation_ref_name = "SATF/" + animation_name + "_" + direction_name
	animation_node.set_animation(animation_ref_name)
	add_blend_point(animation_node, direction_vector)
