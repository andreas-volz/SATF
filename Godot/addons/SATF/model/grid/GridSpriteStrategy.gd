class_name GridSpriteStrategy
extends RefCounted

var _grid_resolver_context: GridResolverContext
var _direction_mapping: SATFDirectionMapping

func set_satf_direction_mapping(direction_mapping_param: SATFDirectionMapping):
	_direction_mapping = direction_mapping_param

func set_resolver_context(context: GridResolverContext):
	_grid_resolver_context = context
	# TODO: check GridResolverContext and fail early

## preview=true does only generate the very first animation to have a fast preview
func normalize(grid_sprite_composition: GridSpriteComposition, preview: bool = false) -> SATFSpriteResource:
	var res := SATFSpriteResource.new()
	var spec := grid_sprite_composition.grid_spec_data
	var layers := grid_sprite_composition.grid_layer_collection
	var texture_slot_registry_map: Dictionary = {} # key=String(path), value=TextureSlot
	var texture_slot_registry_index: Dictionary = {} # key=String(path), value=int(index in res.texture_slot_registry)
	var frame_set_registry_map: Dictionary = {} # key=int(hash_signature), value=SATFFrameRects
	var frame_set_registry_index: Dictionary = {} # key=int(hash_signature), value=int(index in res.frame_set_registry)
	var used_animation_name_list: Array[StringName] = []
	
	var direction_mapping: Array[SATFDirection] = _direction_mapping.direction_mapping
	var direction_mapping_index: Dictionary = {} # key=String(name), value=int(index in Array)
	
	# build Dictionary to access the direction index by name
	for dir_i: int  in direction_mapping.size():
		var direction: SATFDirection = direction_mapping[dir_i]
		direction_mapping_index[direction.name] = dir_i
	
	# before starting calculate the animations Superset from all layers
	var preview_added := false
	var animation_names_combined: Array = []
	for layer: GridLayerData in layers.get_layers():
		if preview_added:
			break
		var animation_names := layer.get_animation_names()
		for anim_name: String in animation_names:
			if preview_added:
				break
			if not animation_names_combined.has(anim_name):
				animation_names_combined.append(anim_name)
				if preview:
					preview_added = true
				
	## fill the layer resource data
	for layer_data: GridLayerData in layers.get_layers():
		var satf_layer := SATFLayer.new()
		satf_layer.z_index = layer_data.z_index.get_or()

		## transform the recolors palette data from the string format into the index format
		var source_colors: PackedColorArray
		var targets_colors: PackedColorArray
		for palette_mapping: PaletteBinding in layer_data.palette_bindings:
			# transform the hex-coded colors into PackedColorArray 
			for color in palette_mapping.source_colors: 
				source_colors.push_back(Color.html(color))
			for color in palette_mapping.target_palette.colors: 
				targets_colors.push_back(Color.html(color))

		satf_layer.recolor = SATFRecolor.new()
		satf_layer.recolor.source_colors = source_colors
		satf_layer.recolor.target_colors = targets_colors
		
		for animation_name in animation_names_combined:
			var satf_layer_animation := SATFLayerAnimation.new()
			
			var anim_layer: GridLayerAnimation = layer_data.get_animation(animation_name)
			var anim_spec: GridSpecAnimation = spec.get_animation(animation_name)
			if anim_spec == null:
				push_warning("skipping not specified animation: ", animation_name)
				continue
		
			var resolved_animation_name: OptionalStringName = _grid_resolver_context.grid_animation_resolver.resolve(anim_spec, layer_data, animation_name)
			if resolved_animation_name.has_value():
				var resolved_animation_index: int = animation_names_combined.find(resolved_animation_name.get_or())
				if resolved_animation_index != -1:
					pass
					
				var texture_path := _grid_resolver_context.grid_path_resolver.resolve(layer_data, resolved_animation_name.get_or())
				
				if texture_path.has_value():
					var binding := SATFLayerBinding.new()
					
					if resolved_animation_name.has_value():
						# save all animations that are really used for the next processing step
						if not used_animation_name_list.has(resolved_animation_name.get_or()):
							used_animation_name_list.append(resolved_animation_name.get_or())
					
					# if the texture isn't yet found in the map then create a new one
					# put the TextureSlot into a map to ensure de-duplication
					if not texture_slot_registry_map.has(texture_path):
						var texture_slot: TextureSlot = TextureSlot.new()
						texture_slot.texture_path = texture_path
						texture_slot_registry_map[texture_path] = texture_slot
						texture_slot_registry_index[texture_path] = res.texture_slot_registry.size()
						res.texture_slot_registry.append(texture_slot)
						
					var binding_texture_ref: int = texture_slot_registry_index[texture_path]
					
					# get new anim_spec from resolved name (we don't need the original one from here)
					anim_spec = spec.get_animation(resolved_animation_name.get_or())
					if anim_spec != null:
						var sprite_size := anim_spec.sprite_size
						
						var texture_rects:GridRectResolver.GridRectSet = _grid_resolver_context.grid_rect_resolver.resolve(texture_path.get_or(), sprite_size)
						
						if anim_spec.get_frame_mode_enum() == GridSpecAnimation.FrameMode.MAPPED:
							satf_layer_animation.frame_mode = SATFLayerAnimation.FrameMode.MAPPED
						elif anim_spec.get_frame_mode_enum() == GridSpecAnimation.FrameMode.LINEAR:
							satf_layer_animation.frame_mode = SATFLayerAnimation.FrameMode.LINEAR
						else:
							push_warning("Unknown FrameMode: ", anim_spec.get_frame_mode_enum())
						
						var signature := calculate_animation_signature(anim_spec, texture_rects)
						
						# if the SATFFrameRects isn't yet found in the map then create a new one
						# put the SATFFrameRects into a map to ensure de-duplication
						if not frame_set_registry_map.has(signature):
							var satf_frame_rects := SATFFrameRects.new()

							for i in direction_mapping.size():
								satf_frame_rects.directions.append(SATFDirectionRects.new())
							
							var row: int  = 0
							for dir_name in anim_spec.directions.get_or():
								var dir_id: int = direction_mapping_index[dir_name]
								var saft_direction_rects: SATFDirectionRects = satf_frame_rects.directions[dir_id]
								for column in range(texture_rects.columns):
									var index: int = row * texture_rects.columns + column
									var rect: Rect2 = texture_rects.rects[index]
									saft_direction_rects.frames.append(rect)
								row += 1

							frame_set_registry_map[signature] = satf_frame_rects
							frame_set_registry_index[signature] = res.frame_rects_registry.size()
							res.frame_rects_registry.append(satf_frame_rects)

						var binding_frame_set_ref: int = frame_set_registry_index[signature]
						
						binding.texture_ref = binding_texture_ref
						binding.frame_rect_ref = binding_frame_set_ref
						satf_layer_animation.binding = binding
			
			satf_layer.animations.append(satf_layer_animation)
			
		res.layers.append(satf_layer)
		
		
	# fill the animations resource data
	for animation_name in used_animation_name_list:
		var anim_spec: GridSpecAnimation = spec.get_animation(animation_name)
		if anim_spec == null:
			push_warning("skipping not specified animation: ", animation_name)
			continue
		
		var satf_animation_frames := SATFAnimationFrames.new()
		satf_animation_frames.name = animation_name
		satf_animation_frames.fps = anim_spec.fps
		
		 # TODO: calculate including offsets
		satf_animation_frames.bounding_box = Rect2(Vector2.ZERO, anim_spec.sprite_size)
		if res.max_bounding_box.abs().size < satf_animation_frames.bounding_box.abs().size:
			res.max_bounding_box = satf_animation_frames.bounding_box
				
		# have a static sized direction array that is always as big as max directions
		for i in direction_mapping.size():
			satf_animation_frames.directions.append(SATFFrameSequence.new())

		# fill the frame_ids data into the correct direction
		var directions_mask := 0
		for dir_name in anim_spec.directions.get_or().keys():
			if direction_mapping_index.has(dir_name):
				var spec_direction: GridSpecAnimationDirection = anim_spec.directions.get_entry_or(dir_name)
				var dir_id: int = direction_mapping_index[dir_name]
				directions_mask |= (1 << dir_id) # Sets the bit at position dir in the mask, marking that direction as present.
				var frame_sequence: SATFFrameSequence = satf_animation_frames.directions[dir_id]
				
				var frames_array: Array = []
				if spec_direction.frames.has_value():
					frames_array = spec_direction.frames.get_or()
				else:
					push_warning("Ignore animation as no 'frames' are defined: ", animation_name)

				frame_sequence.frame_ids = frames_array
				pass
			else:
				push_warning("Direction not found: ", dir_name)

		satf_animation_frames.directions_mask = directions_mask
			
		res.animations.append(satf_animation_frames)
	
	res.direction_standard = _direction_mapping
	
	return res
	
func calculate_animation_signature(anim_spec: GridSpecAnimation, grid_rects: GridRectResolver.GridRectSet) -> int:
	var signature := {
		"size": anim_spec.sprite_size,
		"directions": anim_spec.directions,
		"columns": grid_rects.columns,
		"rows": grid_rects.rows,
	}.hash()
	return signature
	
func deduplicate_sort(frame_ids: Array) -> Array[int]:
	var new_frame_ids: Array[int]
	
	for frame_id: int in frame_ids:
		if not new_frame_ids.has(frame_id):
			new_frame_ids.append(frame_id)
	
	new_frame_ids.sort()
	return new_frame_ids
	
func map_frame_ids(frame_ids: Array) -> Array[int]:
	var new_frame_ids: Array[int]
	var deduplicated_map: Dictionary = {}
	
	for frame_id: int in frame_ids:
		if not deduplicated_map.has(frame_id):
			deduplicated_map[frame_id] = deduplicated_map.size()
	
	for frame_id: int in frame_ids:
		var deduplicated_id: int = deduplicated_map[frame_id]
		new_frame_ids.append(deduplicated_id)
	
	return new_frame_ids
