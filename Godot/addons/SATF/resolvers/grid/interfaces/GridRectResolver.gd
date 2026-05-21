class_name GridRectResolver
extends RefCounted

 ## Rects are stored in ROW-MAJOR order: index = row * columns + column
 ## Outer loop = rows (Y), inner loop = columns (X)
 ## Any other order breaks animation mapping
class GridRectSet:
	var rects: Array[Rect2i] = []
	var columns: int
	var rows: int

func resolve(path: String, sprite_size: Vector2i) -> GridRectSet:
	return null
