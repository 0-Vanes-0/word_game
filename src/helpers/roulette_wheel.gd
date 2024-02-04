class_name RouletteWheel
extends Object


static func spin(variants: Array, weights: Array[int] = []) -> Variant:
	if variants.is_empty():
		print_debug("variants is empty")
		return null
	if weights.is_empty():
		weights.resize(variants.size())
		weights.fill(1)
	elif variants.size() != weights.size():
		print_debug("variants and weights have different sizes")
		return null
	
	var total_weight: int = 0
	for w in weights:
		total_weight += w
	
	var random_value: int = randi_range(1, total_weight)
	var cumulative_size: int = 0
	for i in variants.size():
		cumulative_size += weights[i]
		if random_value <= cumulative_size:
			return variants[i]
	
	return null
