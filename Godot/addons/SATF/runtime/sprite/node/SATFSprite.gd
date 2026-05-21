@tool
class_name SATFSprite
extends LayerSprite2D

signal animation_frame_changed(value: int)

const COLOR_PALETTE_SWAP = preload("uid://c3kw652smxy7b")

# pattern to ensure both setters have run before the _apply_satf_sprite_resource() is able to work
var _satf_sprite_resource_ready
var _graphic_root_path_ready

var _animation_names: Array[StringName]

@export var satf_sprite_resource: SATFSpriteResource : set = set_satf_sprite_resource
@export var graphic_root_path: String :
	set(value):
		graphic_root_path = value
		_graphic_root_path_ready = true
		_apply_satf_sprite_resource()
		
@export var animation_player: SATFAnimationPlayer = null
@export var animation_tree: SATFAnimationTree = null

var animation: int = 0 : set = set_animation
var direction: int = 0 : set = set_direction
var animation_frame: int = 0 : set = set_animation_frame

var _frame_dirty := false

func _ready() -> void:
	super._ready()
	if _satf_sprite_resource_ready == true and _graphic_root_path_ready == true:
		_apply_satf_sprite_resource()
	
	
func set_satf_sprite_resource(resource):
	var animation_player_state := false
	var animation_tree_state := false
	
	# before accessing any data stop the player and tree
	if animation_tree:
		animation_tree_state = animation_tree.active
		animation_tree.active = false
	if animation_player:
		animation_player_state = animation_player.is_playing()
		animation_player.stop()
		
	# then change the resource data
	satf_sprite_resource = resource
	_satf_sprite_resource_ready = true
	_apply_satf_sprite_resource()
	
	# as last step reactivate player and tree (if they were active before)
	if animation_player:
		if animation_player_state:
			animation_player.play()
	if animation_tree:
		if animation_tree_state:
			animation_tree.active = true
	
func _apply_satf_sprite_resource():
	if _satf_sprite_resource_ready == null or _graphic_root_path_ready == null:
		set_layer_count(0) # reset
		notify_property_list_changed()
		return

	if satf_sprite_resource:
		# TODO: this is a hotfix to not crash if a animation is deleted, but a better clean fix is needed!
		# this needs later to be solved to ensure that when changing a resource it's safe and state is clean reset
		var new_animation := clampi(animation, 0, maxi(0, satf_sprite_resource.animations.size()-1))
		set_animation(new_animation)
				
		_cache_animation_names()
		
		var new_layer_count := satf_sprite_resource.layers.size()
		set_layer_count(new_layer_count)


		for layer_i: int in satf_sprite_resource.layers.size():
			var layer: SATFLayer = satf_sprite_resource.layers[layer_i]
			set_layer_z_index(layer.z_index, layer_i)
			
			if layer.recolor != null:
				var shader_material = ShaderMaterial.new()
				shader_material.shader = COLOR_PALETTE_SWAP
				
				if layer.recolor.source_colors.size() == layer.recolor.target_colors.size():
					shader_material.set_shader_parameter("original_colors", layer.recolor.source_colors)
					shader_material.set_shader_parameter("replace_colors", layer.recolor.target_colors)
					shader_material.set_shader_parameter("used_colors", layer.recolor.source_colors.size())
					
					set_layer_material(shader_material, layer_i)
				else:
					push_warning("source color and target colors have not the same size. Ignore recolor request.")
			

		_select_texture()
		region_enabled = true
		
		_fill_animation_player()
		_fill_animation_tree()
		
	else:
		set_layer_count(0) # reset

	notify_property_list_changed()

func _select_texture():
	if satf_sprite_resource:
		#print("_select_texture():")
		for layer_i in satf_sprite_resource.layers.size():
			var layer: SATFLayer = satf_sprite_resource.layers[layer_i]
			
			#if layer.animations.size() <= animation:
				## this ensures the typical case that 
				#continue
			
			var layer_animation: SATFLayerAnimation = layer.animations[animation]
			
			var texture_slot: TextureSlot
			
			if layer_animation.binding != null:
				var texture_ref: int = layer_animation.binding.texture_ref
				texture_slot = satf_sprite_resource.texture_slot_registry[texture_ref]
		
				if texture_slot != null:
					#print("animation_name: ", _animation_names[animation])
					var loaded_texture: Texture2D = null
					if texture_slot.texture_loaded == true:
						loaded_texture = texture_slot.texture
					else:
						var png_name = graphic_root_path + "/" + texture_slot.texture_path.get_or("ERROR") + ".png"
						loaded_texture = UniversalTextureLoader.load_texture(png_name)
						texture_slot.texture_loaded = true
						texture_slot.texture = loaded_texture
						
					if loaded_texture != null:
						assign_texture(loaded_texture, layer_i)
						var frame_set_ref: int = layer_animation.binding.frame_rect_ref
						var frame_set: SATFFrameRects = satf_sprite_resource.frame_rects_registry[frame_set_ref]
						var frame_direction_rects: SATFDirectionRects = frame_set.directions[direction]
						
						var animation_frames: SATFAnimationFrames = satf_sprite_resource.animations[animation]
						var frame_seqence: SATFFrameSequence = animation_frames.directions[direction]
						var frame_id: int = frame_seqence.frame_ids[animation_frame]
						#print("frame_ids: ", frame_seqence.frame_ids)
						#print("animation_frame: ", animation_frame, " frame_id: ", frame_id)
						
						var frame_index: int
						if layer_animation.frame_mode == SATFLayerAnimation.FrameMode.MAPPED:
							frame_index = frame_id
						elif layer_animation.frame_mode == SATFLayerAnimation.FrameMode.LINEAR:
							frame_index = animation_frame
						
						var selected_rect: Rect2 = frame_direction_rects.frames[frame_index]
						
						#print("selected_rect: ", selected_rect.size)
						set_layer_region_rect(selected_rect, layer_i)
					else:
						# if a texture could not be loaded clear the texture on the layer
						clear_layer_texture(layer_i)
			else:
				# if a TextureSlot is not used clear the texture on the layer
				clear_layer_texture(layer_i)

func set_animation(value: int):
	if value == animation:
		return
	else:
		_frame_dirty = true
	
	if satf_sprite_resource:
		animation = clampi(value, 0, maxi(0, satf_sprite_resource.animations.size()-1))
	else:
		animation = 0
	
	# inform the Godot UI property system only for relevant changes and if the value is dirty (really changed)
	# in this case the animation change triggers a UI change for the direction selector
	if _frame_dirty:
		set_direction(direction)
		notify_property_list_changed()

func set_direction(value: int):
	if value == direction and !_frame_dirty:
		return
	else:
		_frame_dirty = true

	if satf_sprite_resource:
		if satf_sprite_resource.animations.size() <= animation:
			push_warning("Try to play a not existing animation: ", animation)
			return
		elif satf_sprite_resource.animations[animation].directions.size() <= direction:
			push_warning("Try to set a not existing direction: ", direction)
			return
			
		# clamp at first to all available animation in the standard mapping
		var direction_clamped := clampi(value, 0, maxi(0, satf_sprite_resource.direction_standard.direction_mapping.size()-1))

		var directions_array: Array[SATFFrameSequence] = satf_sprite_resource.animations[animation].directions
		
		var directions_mask := satf_sprite_resource.animations[animation].directions_mask
		if has_valid_direction(directions_mask, direction_clamped):
			direction = direction_clamped
		else:
			# fallback to the first valid direction for this animation
			var found_dir_fallback := false
			for dir_id in directions_array.size():
				if has_valid_direction(directions_mask, dir_id):
					# BUG: This is really a bug. the fallback mechanism has to change the animation player?
					direction = dir_id
					found_dir_fallback = true
					break
			if found_dir_fallback:
				push_warning("Fallback to existing direction '", direction, "' in animation '", animation, "'")
			else:
				push_error("No direction fallback found for animation '", animation, "'")
		
	else:
		direction = 0
	
	set_animation_frame(animation_frame)

func set_animation_frame(value: int):
	if animation_frame == value and !_frame_dirty:
		return

	if satf_sprite_resource:
		if satf_sprite_resource.animations.size() <= animation:
			push_warning("Try to play a not existing animation: ", animation)
			return
		elif satf_sprite_resource.animations[animation].directions.size() <= direction:
			push_warning("Try to set a not existing direction: ", direction)
			return
		
		var frames_size: int = satf_sprite_resource.animations[animation].directions[direction].frame_ids.size()
		var animation_frame_clamped := clampi(value, 0, maxi(0, frames_size-1))
		animation_frame = animation_frame_clamped
		_select_texture()
	else:
		animation_frame = 0
		
	animation_frame_changed.emit(animation_frame)
	_frame_dirty = false
			
func _fill_animation_player():
	if not animation_player:
		return
		
	for animation_id in range(satf_sprite_resource.animations.size()):
		var animation_name := _animation_names[animation_id]
		var directions: Array[SATFFrameSequence] = satf_sprite_resource.animations[animation_id].directions
		var fps := satf_sprite_resource.animations[animation_id].fps
		
		for direction_id in range(directions.size()):
			var directions_mask := satf_sprite_resource.animations[animation_id].directions_mask
			if has_valid_direction(directions_mask, direction_id):
				var direction_name: String = satf_sprite_resource.direction_standard.direction_mapping[direction_id].name
				var frames_count: int = directions[direction_id].frame_ids.size()
				
				animation_player.create_animation_resource(animation_name, direction_name, animation_id, direction_id, frames_count, fps)
				
func get_animation_names() -> Array[StringName]:
	return _animation_names
	
func _fill_animation_tree():
	if not animation_player or not animation_tree:
		return

	for animation_id in range(satf_sprite_resource.animation_names.size()):
		var animation_name := _animation_names[animation_id]
		
		var directions: Array[SATFFrameSequence] = satf_sprite_resource.animations[animation].directions
		var blend2d_node: SATFAnimationNodeBlendSpace2D = animation_tree.create_animation_blend2d(animation_name)

		for direction_id in range(directions.size()):
			if directions[direction_id] != null:
				var direction_name: String= satf_sprite_resource.direction_standard.direction_mapping[direction_id].name
				var direction_vector: Vector2 = satf_sprite_resource.direction_standard.direction_mapping[direction_id].vector

				blend2d_node.create_animation_blend_point(animation_name, direction_name, direction_vector)
	
func _get_property_list() -> Array:
	var property_usage = PROPERTY_USAGE_DEFAULT
	var properties = []
	
	var animation_property_string = "<null>"
	var direction_property_string = "<null>"
	
	if satf_sprite_resource:
		animation_property_string = SATFUtils.array_to_string(_animation_names, ",")

		var dir_id: int = 0
		var direction_property_array: Array
		
		for directions: SATFFrameSequence in satf_sprite_resource.animations[animation].directions:
			## only work on directions which have any frames
			var directions_mask := satf_sprite_resource.animations[animation].directions_mask
			if has_valid_direction(directions_mask, dir_id):
				## get the name of the direction
				var dir_name: String = satf_sprite_resource.direction_standard.direction_mapping[dir_id].name
				direction_property_array.append(dir_name)
			else:
				direction_property_array.append(null)
			dir_id += 1
		
		direction_property_string = SATFUtils.array_to_string(direction_property_array, ",", true)
	else:
		animation = 0
		direction = 0
		animation_frame = 0
		
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"usage": property_usage,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": animation_property_string
	})

	properties.append({
		"name": "direction",
		"type": TYPE_INT,
		"usage": property_usage,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": direction_property_string
	})
	
	properties.append({
		"name": "animation_frame",
		"type": TYPE_INT,
		"usage": property_usage,
	})

	return properties
	
func _cache_animation_names():
	_animation_names.clear()
	if satf_sprite_resource:
		for animation_frames: SATFAnimationFrames in satf_sprite_resource.animations:
			_animation_names.append(animation_frames.name)

func has_valid_direction(directions_mask: int, dir: int) -> bool:
	return directions_mask & (1 << dir)
