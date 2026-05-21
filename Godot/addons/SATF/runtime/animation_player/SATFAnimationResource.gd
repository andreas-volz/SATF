@tool
class_name SATFAnimationResource
extends Animation

func modify_resource(anim_num: int, direction_num: int, frame_count: int, fps: float) -> SATFAnimationResource:
	var animation_length: float = frame_count / fps
	var animation_step: float = animation_length / frame_count
	self.set_length(animation_length) # how long is our total animation

	var track_index_anim = self.add_track(Animation.TYPE_VALUE)
	self.track_set_path(track_index_anim, ".:animation")
	self.track_insert_key(track_index_anim, 0.0, anim_num)
	self.value_track_set_update_mode(track_index_anim, Animation.UPDATE_DISCRETE)
	
	var track_index_dir = self.add_track(Animation.TYPE_VALUE)
	self.track_set_path(track_index_dir, ".:direction")
	self.track_insert_key(track_index_dir, 0.0, direction_num)
	self.value_track_set_update_mode(track_index_dir, Animation.UPDATE_DISCRETE)

	var track_index_anim_frame = self.add_track(Animation.TYPE_VALUE)
	self.track_set_path(track_index_anim_frame, ".:animation_frame")
	self.value_track_set_update_mode(track_index_anim_frame, Animation.UPDATE_DISCRETE)
	var time = 0.0
	for value in frame_count:
		self.track_insert_key(track_index_anim_frame, time, value)
		time += animation_step

	return self # returns the animation
