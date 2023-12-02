class_name EnemyBattlerStats
extends BattlerStats

@export_range(1, 4) var foe_action_ticks: int = 2
@export_range(1, 4) var ally_action_ticks: int = 2


func _is_stats_valid() -> bool:
	return super() and (
			true
	)


func get_resource() -> BattlerStats:
	var resource_copy = super()
	return resource_copy
