@tool
class_name SATFSpriteControl
extends Control

enum SizeSource {
	CONTAINER, 
	CONTENT 
}

@export var satf_sprite: SATFSprite
@export var create_animation_player: bool = false
@export var create_animation_tree: bool = false
@export var size_source := SizeSource.CONTAINER :
	set(value):
		size_source = value
		update_minimum_size()
@export var sprite_scale := Vector2.ONE :
	set(value):
		sprite_scale = value
		update_minimum_size()
		
func _ready() -> void:
	resized.connect(_on_update_sprite_transform)
	
	if not satf_sprite:
		_internal_create(self, create_animation_player, create_animation_tree)

	satf_sprite.animation_frame_changed.connect(_on_animation_frame_changed)
	
	
func _get_minimum_size() -> Vector2:
	if size_source == SizeSource.CONTAINER:
		return Vector2.ZERO
		
	if not satf_sprite:
		return Vector2.ZERO

	var minimum_size: Vector2 = satf_sprite.get_bounds(SATFSprite.BoundsMode.RESOURCE).abs().size * sprite_scale
	return minimum_size
	
static func _internal_create(control: SATFSpriteControl, animation_player: bool = false, animation_tree: bool = false):
	var sprite := SATFSprite.new()

	control.add_child(sprite)
	control.satf_sprite = sprite
		
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

func _on_animation_frame_changed(value: int):
	#_on_update_sprite_transform()
	update_minimum_size()

func _on_update_sprite_transform() -> void:
	if satf_sprite == null:
		return
		
	var bounds_size: Vector2 = satf_sprite.get_bounds(SATFSprite.BoundsMode.RESOURCE).abs().size
	if bounds_size.x <= 0.0 or bounds_size.y <= 0.0:
		return

	match size_source:
		SizeSource.CONTAINER:
			_apply_fit_container(bounds_size)

		SizeSource.CONTENT:
			_apply_size_to_content(bounds_size)

func _apply_fit_container(bounds_size: Vector2) -> void:
	var scale_factor := min(size.x / bounds_size.x, size.y / bounds_size.y)

	satf_sprite.scale = Vector2.ONE * scale_factor * sprite_scale

	# place in the local middle position - better for UI
	satf_sprite.position = size * 0.5 

func _apply_size_to_content(bounds_size: Vector2) -> void:
	satf_sprite.scale = sprite_scale

	# place in the local middle position - better for UI
	satf_sprite.position = bounds_size * sprite_scale * 0.5
