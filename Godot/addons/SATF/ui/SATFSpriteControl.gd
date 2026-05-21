class_name SATFSpriteControl
extends Control

@export var satf_sprite: SATFSprite
@export var create_animation_player: bool = false
@export var create_animation_tree: bool = false

func _ready() -> void:
	if not satf_sprite:
		_internal_create(self, create_animation_player, create_animation_tree)
	
static func _internal_create(control: SATFSpriteControl, animation_player: bool = false, animation_tree: bool = false):
	var sprite := SATFSprite.new()

	control.add_child(sprite)
	control.satf_sprite = sprite
	
	#control.size = control.satf_sprite.get_size()
	#print(control.satf_sprite.get_size())
	
	if animation_player:
		var ap_node := SATFAnimationPlayer.new()
		sprite.add_child(ap_node)
		sprite.animation_player = ap_node
		
		if animation_tree:
			var at_node := SATFAnimationTree.new()
			sprite.add_child(at_node)
			sprite.animation_tree = at_node
			at_node.anim_player = ap_node.get_path()
	
## factory method to construct it from code
## AnimationTree could only be created if also AnimationPlayer is created
static func create(animation_player: bool = false, animation_tree: bool = false) -> SATFSpriteControl:
	var control := SATFSpriteControl.new()
	_internal_create(control, animation_player, animation_tree)

	return control

func update_size():
	if satf_sprite:
		if satf_sprite.satf_sprite_resource:
			var content_scale := 1
			custom_minimum_size = satf_sprite.satf_sprite_resource.max_bounding_box.abs().size * content_scale
			var satf_offset := satf_sprite.satf_sprite_resource.max_bounding_box.abs().size * (content_scale * 0.5)
			satf_sprite.scale = Vector2(content_scale, content_scale)
			satf_sprite.position = satf_offset
