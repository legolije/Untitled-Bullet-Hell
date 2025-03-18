extends Node

func collision_values(layers: Array[int]) -> int:
	var value = 0
	for layer in layers:
		value |= (1 << (layer - 1))
	return value
