extends Node

#@export var http_node: HTTPManager
#@export var domain: String = "http://192.168.0.25"

var MAX_BATTLERS_COUNT: int = 6

@export_group("Player data", "player_")
@export var player_name := ""
@export var player_donater: bool = false
@export var player_stats: Array[PlayerBattlerStats] = [ Preloader.stats_mage, Preloader.stats_robber, Preloader.stats_knight ]

@export var battlers_types: Array[Battler.Types] = [Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE]
@export var enemy_levels: Array[EnemyLeveling]
@export var coins: int = 0


func _ready() -> void:
	assert(battlers_types.size() == MAX_BATTLERS_COUNT)
	#var has_none := func() -> bool: 
		#for type in battlers_types:
			#if type == Battler.Types.NONE:
				#return true
		#return false
	#
	#assert(not has_none.call())


func add_enemies(level_number: int):
	assert(enemy_levels.size() > 0)
	level_number = clampi(level_number, 1, enemy_levels.size())
	var enemies: Array[Battler.Types]
	for level in enemy_levels:
		if level.level_number == level_number:
			enemies = level.enemies
	
	assert(
			not enemies.is_empty() 
			and enemies.any( func(type: Battler.Types): return type != Battler.Types.NONE  )
	)
	battlers_types[3] = enemies[0]
	battlers_types[4] = enemies[1]
	battlers_types[5] = enemies[2]


func get_level_by_coins(coins: int) -> int:
	return ceili( log(coins / 10) / log(2) + 2 )
# ^
# |
# v
func get_coins_by_level(level: int) -> int:
	return 10 * pow(2, level - 2)


func pay_coins(coins: int) -> bool:
	if GameInfo.coins - coins >= 0:
		GameInfo.coins -= coins
		return true
	else:
		return false
