class_name EnemyBattlerStats
extends BattlerStats

@export var base_reward: int = 1
@export var reward_loss: int = 1
# Add below later
#@export_range(1, 4) var foe_action_ticks: int = 1
#@export_range(1, 4) var ally_action_ticks: int = 1

var reward: int


func _is_stats_valid() -> bool:
	return super() and (
			base_reward > 0
			and base_reward > reward_loss and reward_loss > 0
	)


func get_resource() -> BattlerStats:
	var resource_copy = super()
	reward = base_reward
	return resource_copy


func reduce_reward():
	reward = clampi(reward - reward_loss, 1, base_reward)
