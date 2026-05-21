class_name SATFSpriteResource
extends Resource

@export var direction_standard: SATFDirectionMapping

## [animation_index]
@export var animations: Array[SATFAnimationFrames] = []

## [layer_index]
@export var layers: Array[SATFLayer] = []

## [number of de-duplicated Textures]
@export var texture_slot_registry: Array[TextureSlot] = []

## [number of de-duplicated different animation signatures]
@export var frame_rects_registry: Array[SATFFrameRects] = []

@export var max_bounding_box: Rect2
