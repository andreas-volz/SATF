@tool
class_name LayerSprite2D
extends Node2D

#@export var layer_texture_array: Array[Texture2D] : set = set_layer_texture_array

var layer_count: int = 0 : set = set_layer_count

# This layer not *MUST* contain only Sprite2D children.
var layer_node := Node2D.new()

@export_category("Offset")
#@export var centered: bool = true : set = set_centered
@export var offset: Vector2 : set = set_offset

@export_category("Region")
@export var region_enabled: bool = false : set = set_region_enabled
@export var region_rect: Rect2 : set = set_region_rect

func _ready() -> void:
	add_child(layer_node, false, InternalMode.INTERNAL_MODE_DISABLED)
	
# recreate all layers if count is changed
func set_layer_count(value: int):
	# do nothing if the correct number of layers are yet existing
	if layer_count == value:
		return
	
	layer_count = value
	
	# TODO: remove/add only the changed number of children as optimization
	for child in layer_node.get_children():
		layer_node.remove_child(child)

	for i in layer_count:
		var sprite := Sprite2D.new()
		layer_node.add_child(sprite)
		#sprite.centered = centered
		sprite.offset = offset
		sprite.region_enabled = region_enabled
		sprite.region_rect = region_rect
		
func assign_texture(texture: Texture2D, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.texture = texture
		
#func set_centered(centered_param):
	#centered = centered_param
	#for child in layer_node.get_children():
		#child.centered = centered

func set_offset(offset_param: Vector2):
	offset = offset_param
	for child in layer_node.get_children():
		child.offset = offset
			
#func set_layer_texture_array(texture_array_param: Array[Texture2D]):
	#layer_texture_array = texture_array_param
	#
	#for layer_texture in layer_texture_array:
		#add_layer_texture(layer_texture)
		
#func add_layer_texture(layer_texture: Texture2D):
	#var sprite := Sprite2D.new()
	#sprite.texture = layer_texture
	#add_child(sprite)

func set_region_rect(region_rect_param: Rect2):
	region_rect = region_rect_param
	for child in layer_node.get_children():
		child.region_rect = region_rect

func set_layer_region_rect(region_rect_param: Rect2i, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.region_rect = region_rect_param

func set_region_enabled(region_enabled_param: bool):
	region_enabled = region_enabled_param
	for sprite: Sprite2D in layer_node.get_children():
		sprite.region_enabled = region_enabled

func set_all_visible(visible_param: bool):
	for sprite: Sprite2D in layer_node.get_children():
		sprite.visible = visible_param

func set_layer_visible(visible_param: bool, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.visible = visible_param
		
func set_layer_region_enabled(region_enabled_param: bool, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.region_enabled = region_enabled_param
	
func set_layer_z_index(z_index_param: int, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.z_index = z_index_param
	_normalize_z_index()

func clear_layer_texture(layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.texture = null

func set_layer_material(material: Material, layer: int):
	if layer < layer_count:
		var sprite: Sprite2D = layer_node.get_child(layer)
		sprite.material = material

#####################
## internal functions
#####################

## shift the internal Node2D 'layer_node' so many z_index values that the smallest is always zero
## this allows the LayerSprite2D itself to behave neutral and consistence to the outside even for negative z_index children
func _normalize_z_index():
	var z_layer_min: int
	for child: Sprite2D in layer_node.get_children():
		var z_layer := child.z_index
		if z_layer < z_layer_min:
			z_layer_min = z_layer
	layer_node.z_index = -z_layer_min
		
