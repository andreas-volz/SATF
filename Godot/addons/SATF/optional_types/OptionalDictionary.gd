class_name OptionalDictionary
extends Resource

@export var _has_value: bool = false
@export var _value: Dictionary = {}

func set_value(v: Dictionary) -> void:
	_value = v
	_has_value = true

func clear() -> void:
	_has_value = false
	_value.clear()

## get the Dictionary itself (if available) or the default parameter
func get_or(default: Dictionary = {}) -> Dictionary:
	return _value if _has_value else default

## Check if there's a Dictionary created as value
## Don't mix this up with contains() which checks for a value in the Dictionary itself!
func has_value() -> bool:
	return _has_value

## check if a key is contained in the Dictionary
## if there is no Dictionary created then return false
func contains(key: Variant) -> bool:
	return _has_value and _value.has(key)

## try to get an entry from the Dictionary.
## This functions could return null if you don't specify a default return
func get_entry_or(key: Variant, default: Variant = null):
	if not _has_value:
		return default
	return _value.get(key, default)

## set a entry into the Dictionary.
## if not yet created initialize the value itself with a new Dictionary
func set_entry(key: Variant, entry: Variant) -> void:
	if not _has_value:
		_has_value = true
		_value = {}
	_value[key] = entry
