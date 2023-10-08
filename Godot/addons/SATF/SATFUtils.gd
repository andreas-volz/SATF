class_name Utils
extends Node

static func array_to_string(string_array: Array[String], separator: String) -> String:
	var result_string: String = ""
	var counter = 0
	for str_element in string_array:
		result_string += str_element
		if counter < string_array.size() - 1:
			result_string += separator
		counter += 1
	return result_string
