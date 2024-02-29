@tool
class_name EnemyLevel
extends Resource

@export var enemies: Array[Battler.Types] = [ Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE ] :
	set(value):
		_calc_coin_summ(value)
		enemies = value
@export var coin_summ: int = 0 # DO NOT EDIT THIS VAR
var level_number: int = 1

const REWARDS := {
	Battler.Types.NONE: 0,
	Battler.Types.ENEMY_GOBLIN: 10,
	Battler.Types.ENEMY_FIRE_IMP: 15,
	Battler.Types.ENEMY_BEAR: 20,
	Battler.Types.ENEMY_ENT: 30,
	Battler.Types.ENEMY_SNAKE: 40,
	Battler.Types.ENEMY_ORC: 60,
}


func _calc_coin_summ(array: Array[Battler.Types]):
	coin_summ = 0
	for type in array:
		coin_summ += REWARDS.get(type) as int
