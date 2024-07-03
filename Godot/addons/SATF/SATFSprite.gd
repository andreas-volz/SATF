@tool
class_name SATFSprite
extends Sprite2D

const direction_vectors_iso = {
	"S" 	: Vector2(0, 1),
	"N" 	: Vector2(0, -1),
	"W" 	: Vector2(-1, 0),
	"E"		: Vector2(1, 0),
	"SW" 	: Vector2(-1, 1),
	"SE" 	: Vector2(1, 1),
	"NW" 	: Vector2(-1, -1),
	"NE"	: Vector2(1, -1),
}

const direction_vectors_lpc = {
	"up" 	: Vector2(0, -1),
	"down" 	: Vector2(0, 1),
	"left" 	: Vector2(-1, 0),
	"right"	: Vector2(1, 0),
}

enum DirectionStandard {
	ISO,
	LPC
}

@export_file("metadata.json") var metadata = "" : set = set_metadata
@export var direction_standard: DirectionStandard = 0

var json_dict: Dictionary

var animation_frame = 0 : set = set_animation_frame
var animation: int = 0 : set = _set_animation_property
var direction: int = 0 : set = _set_direction_property

var animation_property_array: Array[String] = []
var direction_property_array: Array[String] = []

var _texture_container := {}

var _shadow: SATFShadow = null

func _enter_tree():
	pass
	
func _init() -> void:
	pass

func _ready() -> void:
	if metadata == null:
		return
		
	_setup_shadow()
		
# this function loads the needed animation textures referenced in the json file
# as it search textures in several places it's possible to "patch" a big textures single frame
func _load_textures(path: String):
	var check_texture: String
	
	_texture_container.clear()
	
	check_texture = path + "/" + "animations.png"
	if ResourceLoader.exists(check_texture):
		var texture_key = "animations"
		#print("load texture: " + check_texture + " -> " + texture_key)
		var texture_value: Texture2D = load(check_texture)
		_texture_container[texture_key] = texture_value
		
	for animation_name in json_dict['animations']:
		check_texture = path + "/" + animation_name + ".png"
		if ResourceLoader.exists(check_texture):
			var texture_key = "animations-" + animation_name
			#print("load texture: " + check_texture + " -> " + texture_key)
			var texture_value: Texture2D = load(check_texture)
			_texture_container[texture_key] = texture_value
			
		check_texture = path + "/animations-" + animation_name + ".png"
		if ResourceLoader.exists(check_texture):
			var texture_key = "animations-" + animation_name
			#print("load texture: " + check_texture + " -> " + texture_key)
			var texture_value: Texture2D = load(check_texture)
			_texture_container[texture_key] = texture_value
		
		for direction_name in json_dict['animations'][animation_name]:
			check_texture = path + "/" + animation_name + "/" + direction_name + ".png"
			if ResourceLoader.exists(check_texture):
				var texture_key = "animations-" + animation_name + "-" + direction_name
				#print("load texture: " + check_texture + " -> " + texture_key)
				var texture_value: Texture2D = load(check_texture)
				_texture_container[texture_key] = texture_value
				
			check_texture = path + "/animations-" + animation_name + "-" + direction_name + ".png"
			if ResourceLoader.exists(check_texture):
				var texture_key = "animations-" + animation_name + "-" + direction_name
				#print("load texture: " + check_texture + " -> " + texture_key)
				var texture_value: Texture2D = load(check_texture)
				_texture_container[texture_key] = texture_value
				
			var frame_counter = 0
			for frame_object in json_dict['animations'][animation_name][direction_name]:
				var frame_name = frame_object["name"]
				check_texture = path + "/" + animation_name + "/" + direction_name + "/" + frame_name + ".png"
				if ResourceLoader.exists(check_texture):
					var texture_key = "animations-" + animation_name + "-" + direction_name + "-" + str(frame_counter)
					#print("load texture: " + check_texture + " -> " + texture_key)
					var texture_value: Texture2D = load(check_texture)
					_texture_container[texture_key] = texture_value
					
				check_texture = path + "/" + animation_name + "-" + direction_name + "-" + frame_name + ".png"
				if ResourceLoader.exists(check_texture):
					var texture_key = "animations-" + animation_name + "-" + direction_name + "-" + str(frame_counter)
					#print("load texture: " + check_texture + " -> " + texture_key)
					var texture_value: Texture2D = load(check_texture)
					_texture_container[texture_key] = texture_value
				
				frame_counter += 1
	
func _fill_animation_player() -> SATFAnimationPlayer:
	var animation_player: SATFAnimationPlayer = null
	
	var child_nodes: Array[Node] = get_children()
	for cn in child_nodes:
		if cn is SATFAnimationPlayer:
			animation_player = cn
			break

	if animation_player:
		var animation_counter = 0
		for animation_name in json_dict['animations']:
			var direction_counter = 0
			for direction_name in json_dict['animations'][animation_name]:
				var frame_count = json_dict['animations'][animation_name][direction_name].size()
				var fps = json_dict['fps']
				animation_player.create_animation_resource(animation_name, direction_name, animation_counter, direction_counter,frame_count, fps)
				direction_counter += 1
			animation_counter += 1
			
	return animation_player
	
func _fill_animation_tree(animation_player: SATFAnimationPlayer):
	var animation_tree: SATFAnimationTree = null
	assert(animation_player)
	
	var child_nodes: Array[Node] = get_children()
	for cn in child_nodes:
		if cn is SATFAnimationTree:
			animation_tree = cn
			break
			
	if animation_tree:
		for animation_name in json_dict['animations']:
			var blend2d_node: SATFAnimationNodeBlendSpace2D = animation_tree.create_animation_blend2d(animation_name)

			for direction_name in json_dict['animations'][animation_name]:
				
				# primitive implementation to switch between ISO and LPC name "standard"
				# if there is any need later make it flexible as exported list
				var direction_vector: Vector2
				if direction_standard == DirectionStandard.ISO:
					direction_vector = direction_vectors_iso[direction_name]
				elif direction_standard == DirectionStandard.LPC:
					direction_vector = direction_vectors_lpc[direction_name]
					
				blend2d_node.create_animation_blend_point(animation_name, direction_name, direction_vector)
				
func _setup_shadow():
	var child_nodes: Array[Node] = get_children()
	for cn in child_nodes:
		if cn is PointLight2D:
			_shadow = cn
			break
			
func set_metadata(value):
	metadata = value
	
	_read_metadata_json(metadata.get_base_dir())
	_fill_inspector_animation_properties()
	_load_textures(metadata.get_base_dir())
		
	centered = false
	var animation_player = _fill_animation_player()
	if animation_player:
		_fill_animation_tree(animation_player)
		
	configure_animation(animation_property_array[animation], direction_property_array[direction], animation_frame)

func _set_animation_property(value):
	animation = value
	# fill again after choosing animation in case different available directions
	_fill_inspector_direction_properties()
	direction = 0
	
	select_texture()
	if animation_property_array.size() > 0 and direction_property_array.size() > 0:
		configure_animation(animation_property_array[animation], direction_property_array[direction], animation_frame)

func _set_direction_property(value):
	direction = value
	
	select_texture()
	if animation_property_array.size() > 0 and direction_property_array.size() > 0:
		configure_animation(animation_property_array[animation], direction_property_array[direction], animation_frame)

	
func select_texture():
	if animation_property_array.size() == 0 or direction_property_array.size() == 0:
		return
		
	var texture_key_animations_complete = "animations"
	var texture_key_animation = texture_key_animations_complete + "-" + animation_property_array[animation]
	var texture_key_direction = texture_key_animation + "-" + direction_property_array[direction]
	var texture_key_frame = texture_key_direction + "-" + str(animation_frame)
	
	var new_texture: Texture2D = null
	if _texture_container.has(texture_key_frame):
		new_texture = _texture_container[texture_key_frame]
	elif _texture_container.has(texture_key_direction):
		new_texture = _texture_container[texture_key_direction]
	elif _texture_container.has(texture_key_animation):
		new_texture = _texture_container[texture_key_animation]
	elif _texture_container.has(texture_key_animations_complete):
		new_texture = _texture_container[texture_key_animations_complete]
	
	if new_texture != null and new_texture != texture:
		texture = new_texture
	
func _get_property_list() -> Array:
	var property_usage = PROPERTY_USAGE_DEFAULT

	var animation_property_string = SATFUtils.array_to_string(animation_property_array, ",")
	var properties = []
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"usage": property_usage,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": animation_property_string
	})
	
	var direction_property_string = SATFUtils.array_to_string(direction_property_array, ",")
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
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,20,1"
	})

	return properties

func _fill_inspector_animation_properties() -> void:
	animation_property_array.clear()
	for animation_name in json_dict['animations']:
		animation_property_array.append(animation_name)

	_fill_inspector_direction_properties()
	notify_property_list_changed()

func _fill_inspector_direction_properties() -> void:
	direction_property_array.clear()
	for direction_name in json_dict['animations'][animation_property_array[animation]]:
		direction_property_array.append(direction_name)
	
	notify_property_list_changed()
	
func _read_metadata_json(path: String):
	var file = path + "/metadata.json"
	var json_string = FileAccess.get_file_as_string(file)
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else:
		json_dict = json.data

func set_animation_frame(value):
	animation_frame = value
	if animation_property_array.size() > 0 and direction_property_array.size() > 0:
		configure_animation(animation_property_array[animation], direction_property_array[direction], value)

func configure_animation(animation_name: String, direction_name: String, number: int):
	assert(json_dict.has("animations"))
	var animation_json_dict = json_dict["animations"][animation_name]
	
	assert(animation_json_dict[direction_name] is Array)
	var direction_json_array: Array = animation_json_dict[direction_name]
	
	number = clamp(number, 0, direction_json_array.size()-1)
	
	var frame_json = direction_json_array[number]
	
	select_texture()
	
	if frame_json.has("origin"):
		var origin_json = frame_json["origin"]
		offset.x = -origin_json["x"]
		offset.y = -origin_json["y"]
	else:
		if json_dict.has("origin"):
			var origin = json_dict["origin"]
			offset.x = origin.x
			offset.y = origin.y
		else:
			offset.x = 0
			offset.y = 0
	
	if frame_json.has("rect"):
		var rect_json = frame_json["rect"]
		var frame_rect = Rect2(rect_json["x"], rect_json["y"], rect_json["w"], rect_json["h"])
		region_enabled = true
		region_rect = frame_rect
	else:
		region_enabled = false
		region_rect = Rect2(0, 0, 0, 0)
		
	if _shadow != null:
		_shadow.texture_scale_xy = Vector2(region_rect.size.x * 2, region_rect.size.y)
		#shadow.position.x = region_rect.size.x/2.0 + offset.x
		#shadow.position.y = region_rect.size.y + offset.y
		#_shadow.texture.width = region_rect.size.x * 2
		#_shadow.texture.height = region_rect.size.y 

