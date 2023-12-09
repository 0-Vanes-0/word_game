extends Node

#@export var http_node: HTTPManager
#@export var domain: String = "http://192.168.0.25"

var MAX_BATTLERS_COUNT: int = 6

@export_group("Player data", "player_")
@export var player_name := ""
@export var player_level: int = 1
@export var player_donater: bool = false

@export var battlers_types: Array[Battler.Types] = [Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE]
@export var max_enemies_level: int = 1


#func _ready() -> void:
	#var has_none := func() -> bool: 
		#for type in battlers_types:
			#if type == Battler.Types.NONE:
				#return true
		#return false
	#
	#assert(battlers_types.size() == MAX_BATTLERS_COUNT)
	#assert(not has_none.call())


func add_enemies(level: int):
	level = clampi(level, 1, max_enemies_level)
	match level:
		1:
			battlers_types[3] = Battler.Types.GOBLIN
			battlers_types[4] = Battler.Types.GOBLIN
			battlers_types[5] = Battler.Types.NONE
		2:
			battlers_types[3] = Battler.Types.GOBLIN
			battlers_types[4] = Battler.Types.GOBLIN
			battlers_types[5] = Battler.Types.GOBLIN
		3:
			battlers_types[3] = Battler.Types.GOBLIN
			battlers_types[4] = Battler.Types.FIRE_IMP
			battlers_types[5] = Battler.Types.NONE
		4:
			battlers_types[3] = Battler.Types.GOBLIN
			battlers_types[4] = Battler.Types.FIRE_IMP
			battlers_types[5] = Battler.Types.FIRE_IMP
