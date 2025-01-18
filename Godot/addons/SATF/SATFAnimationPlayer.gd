@tool
class_name SATFAnimationPlayer
extends AnimationPlayer
	
func _ready() -> void:
	if not get_animation_library("SATF"):
		var anim_lib = AnimationLibrary.new()
		add_animation_library("SATF", anim_lib)

	
func create_animation_resource(anim_name: String, direction : String, anim_num: int, direction_num: int, frame_count: int, fps: float, overwrite = false):
	var animation = SATFAnimationResource.new()
	var animation_library = self.get_animation_library("SATF")
	
	var full_name = anim_name + "_" + direction
	if animation_library.has_animation(full_name) and overwrite == false:
		var existing_animation = animation_library.get_animation(full_name)
		existing_animation.remove_track(existing_animation.find_track(".:animation", Animation.TYPE_VALUE))
		existing_animation.remove_track(existing_animation.find_track(".:direction", Animation.TYPE_VALUE))
		existing_animation.remove_track(existing_animation.find_track(".:animation_frame", Animation.TYPE_VALUE))
		existing_animation.modify_resource(anim_num, direction_num, frame_count, fps)
		#print("animation yet existing")
	else:
		animation.modify_resource(anim_num, direction_num, frame_count, fps)
		animation_library.add_animation(full_name, animation)
	
	return animation
