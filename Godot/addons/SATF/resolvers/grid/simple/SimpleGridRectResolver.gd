class_name SimpleGridRectResolver
extends GridRectResolver

var _graphic_root_path: String

func resolve(path: String, sprite_size: Vector2i) -> GridRectSet:
	var image_path := _graphic_root_path + "/" + path + ".png"
	var image_size: Vector2i = UniversalTextureLoader.get_size(image_path)
	#print(image_size)
	
	var column_mod := image_size.x % sprite_size.x
	var row_mod := image_size.y % sprite_size.y
	
	if column_mod != 0:
		push_warning("The image %s has %d column pixel truncated to fit the grid layout", image_path, column_mod)
	if row_mod != 0:
		push_warning("The image %s has %d row pixel truncated to fit the grid layout", image_path, row_mod)
		
	var column_count := image_size.x / sprite_size.x
	var row_count := image_size.y / sprite_size.y
	
	var grid_rect_set := GridRectSet.new()
	grid_rect_set.columns = column_count
	grid_rect_set.rows = row_count
	for row_pos: int in range(row_count):
		for column_pos: int in range(column_count):
			var frame_rect = Rect2i(sprite_size.x * column_pos,
								sprite_size.y * row_pos,
								sprite_size.x,
								sprite_size.y)
			grid_rect_set.rects.append(frame_rect)
	
	return grid_rect_set
