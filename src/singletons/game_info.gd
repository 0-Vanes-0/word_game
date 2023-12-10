extends Node

#@export var http_node: HTTPManager
#@export var domain: String = "http://192.168.0.25"

var MAX_BATTLERS_COUNT: int = 6

@export_group("Player data", "player_")
@export var player_name := ""
@export var player_level: int = 1
@export var player_donater: bool = false

@export var battlers_types: Array[Battler.Types] = [Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE]
@export var levels: Array[EnemyLeveling]


#func _ready() -> void:
	#var has_none := func() -> bool: 
		#for type in battlers_types:
			#if type == Battler.Types.NONE:
				#return true
		#return false
	#
	#assert(battlers_types.size() == MAX_BATTLERS_COUNT)
	#assert(not has_none.call())


func add_enemies(level_number: int):
	assert(levels.size() > 0)
	level_number = clampi(level_number, 1, levels.size())
	var enemies: Array[Battler.Types]
	for level in levels:
		if level.level_number == level_number:
			enemies = level.enemies
	
	assert(
			not enemies.is_empty() 
			and enemies.any( func(type: Battler.Types): return type != Battler.Types.NONE  )
	)
	battlers_types[3] = enemies[0]
	battlers_types[4] = enemies[1]
	battlers_types[5] = enemies[2]
