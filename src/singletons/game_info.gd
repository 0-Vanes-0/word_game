extends Node

#@export var http_node: HTTPManager
#@export var domain: String = "http://192.168.0.25"

const MAX_BATTLERS_COUNT: int = 6

@export var heroes_types: Array[int] = [Battler.HeroTypes.NONE, Battler.HeroTypes.NONE, Battler.HeroTypes.NONE]
@export var enemies_types: Array[int] = [Battler.EnemyTypes.NONE, Battler.EnemyTypes.NONE, Battler.EnemyTypes.NONE]
@export var enemy_levels: Array[EnemyLevel]
@export var current_enemy_level: int


func _ready() -> void:
	assert(enemy_levels.size() > 0)
	for i in enemy_levels.size():
		enemy_levels[i].level_number = i+1


func add_enemies(level_number: int):
	current_enemy_level = clampi(level_number, 1, enemy_levels.size())
#	var enemies: Array[Battler.EnemyTypes]
#	for level in enemy_levels:
#		if level.level_number == current_enemy_level:
#			enemies = level.enemies
#
#	assert(
#			not enemies.is_empty()
#			and enemies.any( func(type: Battler.EnemyTypes): return type != Battler.EnemyTypes.NONE  )
#	)
#	battlers_types[3] = enemies[0]
#	battlers_types[4] = enemies[1]
#	battlers_types[5] = enemies[2]


func get_level_by_coins(coins: int) -> int:
	return ceili( log(coins / 10) / log(2) + 2 )
# ^
# |
# v
func get_coins_by_level(level: int) -> int: # 10, 15, 25, 40, 60...
	assert(level >= 2)
	var x := level - 2
	return 2.5*x*x + 2.5*x + 10


func pay_coins(coins: int) -> bool:
	var player_coins := int(Global.get_player_coins())
	if player_coins - coins >= 0:
		Global.set_player_coins(player_coins - coins)
		return true
	else:
		return false


func has_coins(coins: int) -> bool:
	var player_coins := int(Global.get_player_coins())
	if player_coins - coins >= 0:
		return true
	else:
		return false


func get_enemy_level(level: int) -> EnemyLevel:
	for enemy_level in enemy_levels:
		if enemy_level.level_number == level:
			return enemy_level
	return null
