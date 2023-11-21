extends Node

#@export var http_node: HTTPManager
#@export var domain: String = "http://192.168.0.25"

var MAX_BATTLERS_COUNT: int = 6

@export_group("Player data", "player_")
@export var player_name := ""
@export var player_level: int = 1
@export var player_donater: bool = false

#const BATTLER_ENUM = Battler.Types
@export var battlers_types: Array[Battler.Types] = [Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE]


func _ready() -> void:
	var has_none := func() -> bool: 
		for type in battlers_types:
			if type == Battler.Types.NONE:
				return true
		return false
	
	assert(battlers_types.size() == MAX_BATTLERS_COUNT)
	assert(not has_none.call())
