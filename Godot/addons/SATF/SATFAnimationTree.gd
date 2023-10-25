@tool
class_name SATFAnimationTree
extends AnimationTree

var _count = 0

var animation_variant = "Animation"

func _init() -> void:
	create_animation_tree()

func _ready() -> void:
	var anim_player_path: NodePath
	var child_nodes: Array[Node] = get_parent().get_children()
	for cn in child_nodes:
		if cn is SATFAnimationPlayer:
			anim_player_path = cn.get_path()
			break
	
	anim_player = anim_player_path
	active = true
	
func create_animation_tree() -> void:
	# only create a new StateMachine in case it's not yet exsiting
	# this is a good way to clean the StateMachine in case it's needed
	if tree_root == null:
		tree_root = AnimationNodeStateMachine.new()
	
func create_animation_blend2d(animation_name : String) -> SATFAnimationNodeBlendSpace2D:
	var blend2d_node := SATFAnimationNodeBlendSpace2D.new()
	blend2d_node.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
	
	var animation_statemachine: AnimationNodeStateMachine = tree_root
	
	if not animation_statemachine.has_node(animation_name):
		## this is only for AnimationTree visibility
		var x = 400
		var y = _count * 100

		#print("add node: " + animation_name)
		animation_statemachine.add_node(animation_name, blend2d_node, Vector2(x, y))
		
	_count += 1
	
	return blend2d_node
	
func create_animation_transition(initial_animation_name : String, animation_name : String) -> void:
	var animation_transition = AnimationNodeStateMachineTransition.new()
	var animation_transition_back = AnimationNodeStateMachineTransition.new()
	var animation_statemachine: AnimationNodeStateMachine = tree_root
	
	animation_statemachine.add_transition(initial_animation_name, animation_name, animation_transition)
	animation_statemachine.add_transition(animation_name, initial_animation_name , animation_transition_back)
	
func travel(to_node: String):
	var _animation_state = get("parameters/playback")
	_animation_state.travel(to_node)

func set_check(property: StringName, value: Variant):
	if self.get(property) != null:
		self.set(property, value)
	else:
		print("Property not found: " + property)
		
	
