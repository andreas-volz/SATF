class_name TextureSlot
extends Resource

@export var texture: Texture2D

@export var texture_loaded: bool = false # for lazy loading

@export var texture_path: OptionalString = OptionalString.new()
