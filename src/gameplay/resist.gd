class_name Resist
extends Resource

enum Types {
	NONE, DEATHS_DOOR, FIRE
}

@export var type: Types = Types.NONE
@export_range(0, 100) var base_value: int

var value: int


func _is_stats_valid() -> bool:
	return type != Types.NONE and 0 <= base_value and base_value <= 100


func get_resource() -> Resist:
	var resource_copy := self.duplicate()
	assert(_is_stats_valid())
	resource_copy.value = base_value
	return resource_copy


func try_to_resist() -> bool:
	var random_value := randi_range(1, 100)
	#print_debug("random_value=", random_value, " value=", value)
	if random_value <= value:
		if type == Types.DEATHS_DOOR:
			value = clampi(value - 10, 0, 100)
		return true
	else:
		return false


static func get_resist_icon(type: Types) -> Texture2D:
	match type:
		Types.DEATHS_DOOR:
			return Preloader.texture_skull
		#Types.FIRE:
			#return 
		_:
			assert(false, "Wrong type: " + str(type))
			return Texture2D.new()
