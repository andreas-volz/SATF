class_name SATFLayerAnimation
extends Resource

@export var binding: SATFLayerBinding

enum FrameMode {
	LINEAR,
	MAPPED
}

@export var frame_mode: FrameMode = FrameMode.MAPPED
