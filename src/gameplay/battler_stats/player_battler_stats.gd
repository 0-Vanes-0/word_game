class_name PlayerBattlerStats
extends BattlerStats

@export var runes: Array[Rune]
@export var level: int = 1


func _is_stats_valid() -> bool:
	return super() and (
			2 <= runes.size() and runes.size() <= 4
			and level >= 1
	)


func get_resource() -> BattlerStats:
	var resource_copy = super()
	return resource_copy
