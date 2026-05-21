class_name AssetReference
extends RefCounted

var base_path: String
var variant := OptionalString.new()

func _init(base_path_param: String = "", variant_param: String = "") -> void:
	base_path = base_path_param
	if not variant_param.is_empty():
		variant.set_value(variant_param)

func clone() -> AssetReference:
	return AssetReference.new(base_path, variant.get_or())

func to_dict() -> Dictionary:
	var asset_ref_dict: Dictionary = {}
	
	asset_ref_dict["base_path"] = base_path
	
	if variant.has_value():
		asset_ref_dict["variant"] = variant.get_or()
	
	return asset_ref_dict
