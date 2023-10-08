@tool
class_name SATFAnimationNodeBlendSpace2D
extends AnimationNodeBlendSpace2D

const direction_vectors = {
	"S" 	: Vector2(0, 1),
	"N" 	: Vector2(0, -1),
	"W" 	: Vector2(-1, 0),
	"E"		: Vector2(1, 0),
	"SW" 	: Vector2(-1, 1),
	"SE" 	: Vector2(1, 1),
	"NW" 	: Vector2(-1, -1),
	"NE"	: Vector2(1, -1),
}

func get_resource(_root_node: AnimationRootNode) -> SATFAnimationNodeBlendSpace2D:
	return self

func create_animation_blend_point(animation_name : String, direction : String):
	var animation_node := AnimationNodeAnimation.new()
	var blend_pos: Vector2 = direction_vectors[direction]
	
	var animation_ref_name = "SATF/" + animation_name + "_" + direction
	animation_node.set_animation(animation_ref_name)
	add_blend_point(animation_node, blend_pos)
