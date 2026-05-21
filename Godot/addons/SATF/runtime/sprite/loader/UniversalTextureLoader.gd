class_name UniversalTextureLoader
extends RefCounted

# Generic loader for textures from multiple sources:
# - res:// (imported resources)
# - user:// or OS paths (raw files)
# - optionally compressed with PortableCompressedTexture2D
# Future extension: ZIP files, network URLs, etc.

static func exists(path: String) -> bool:
	if path.begins_with("res://") and ResourceLoader.exists(path):
		return true
	elif FileAccess.file_exists(path):
		return true
	return false

static func get_size(path: String) -> Vector2i:
	var img := Image.new()
	img.load(path)
	var size := img.get_size()
	return size

# Loads a single texture from a given path
static func load_texture(path: String, portable_compressed: bool = false) -> Texture2D:
	var tex: Texture2D = null

	# Imported resource
	if path.begins_with("res://"):
		tex = ResourceLoader.load(path)
	else:
		if portable_compressed:
			tex = PortableCompressedTexture2D.new()
			var portable_image: Image = Image.new()
			portable_image = Image.load_from_file(path)
			if portable_image == null:
				push_warning("Failed to load image: %s" % path)
			tex.create_from_image(portable_image, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS)
		else:
			var image := Image.load_from_file(path)
			if image == null:
				push_warning("Failed to load image: %s" % path)
				return null
			image.convert(Image.FORMAT_RGBA8)
			tex = ImageTexture.create_from_image(image)

	return tex

# Loads multiple textures (e.g., for animation frames)
static func load_textures(paths: Array, portable_compressed: bool = false) -> Array:
	var textures := []
	for path in paths:
		var tex = load_texture(path, portable_compressed)
		if tex:
			textures.append(tex)
	return textures
