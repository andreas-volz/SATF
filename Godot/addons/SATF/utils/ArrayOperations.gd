class_name ArrayOperations
extends RefCounted

## Returns a new Array containing the elements of the input Array in their original order,
## with duplicates removed (first occurrence is kept).
## Uniqueness is enforced using has() checks.
## If the input is null, an empty Array is returned.
## The original input Array is not modified.
static func union_array(array: Array) -> Array:
	if array == null:
		return []
	
	var new_array: Array = []
	var seen := {}
		
	for a in array:
		if not seen.has(a):
			seen[a] = true
			new_array.append(a)
	
	return new_array

## Merges two Arrays into a new Array while preserving order of first occurrence.
## Duplicate elements are removed; uniqueness is enforced using has() checks.
## Elements from array_a are included first, followed by elements from array_b
## that are not already present in array_a.
## If both inputs are null, an empty Array is returned.
## If only one input is null, the union of the non-null Array is returned.
## The original input Arrays are not modified.
static func union_array_merge(array_a: Array, array_b: Array) -> Array:
	if array_a == null and array_b == null:
		return []
	elif array_a == null:
		return union_array(array_b)
	elif array_b == null:
		return union_array(array_a)
		
	var array_new: Array = []
	var seen := {}
	
	for a in array_a:
		if not seen.has(a):
			seen[a] = true
			array_new.append(a)

	for a in array_b:
		if not seen.has(a):
			seen[a] = true
			array_new.append(a)
	
	return array_new
	
## Returns a new Array containing the union of the input array and a single element.
## Duplicates are removed based on first occurrence; the original order is preserved.
## The input array is not modified.
## The element is appended only if it is not already present in the array.
## Uses a hash-based lookup (seen) for O(n) performance.
## Returns an empty Array if the input array is null.
static func union_array_append_unique(array: Array, element: Variant) -> Array:
	var array_new: Array = []
	var seen := {}

	if array != null:
		for a in array:
			if not seen.has(a):
				seen[a] = true
				array_new.append(a)

	if element != null and not seen.has(element):
		array_new.append(element)

	return array_new
