class_name GridSpriteComposition
extends Resource

## --- Properties ---

## Grid-based specification data
var _grid_spec: GridSpecData = null

## Layer-based animation data
var _grid_layers: GridLayerCollection = null

var _material_registry: MaterialRegistry = null

# TODO: think about to put this somewhere else as SATF* is the wrong architecture layer here
var _direction_mapping: SATFDirectionMapping = null

## --- Public Functions ---

## Compose spec and layers into a single normalized SpriteDefinition (grid-based)
func compose(grid_spec_param: GridSpecData, grid_layers_param: GridLayerCollection, material_registry_param: MaterialRegistry) -> void:
	_grid_spec = grid_spec_param
	_grid_layers = grid_layers_param
	_material_registry = material_registry_param

func set_satf_direction_mapping(direction_mapping_param: SATFDirectionMapping):
	_direction_mapping = direction_mapping_param

## Retrieve a specific animation layer by name
#func get_layer(layer_name: String) -> GridLayerAnimation:
	#return

## Check if a layer exists
#func has_layer(layer_name: String) -> bool:
	#return false

## Merge another GridSpriteComposition into this one, combining layers, rect data, and metadata
#func merge_with(other: GridSpriteComposition) -> void:
	#pass

## Return all layer names
func get_layer_names() -> Array[String]:
	var layer_names: Array[String]= []
	return layer_names

## Return a deep copy of this GridSpriteComposition
#func duplicate_data() -> GridSpriteComposition:
	#return

## Optional helper: validate internal data integrity
#func validate() -> bool:
	#return false

## --- Internal / Parsing Helpers ---
