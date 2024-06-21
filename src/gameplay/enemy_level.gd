@tool
class_name EnemyLevel
extends Resource

@export var enemies: Array[Battler.EnemyTypes] = [ Battler.EnemyTypes.NONE, Battler.EnemyTypes.NONE, Battler.EnemyTypes.NONE ] :
	set(value):
		#_calc_coin_summ(value)
		enemies = value
@export var coin_summ: int = 0 # DO NOT EDIT THIS VAR
var level_number: int = 1

const REWARDS := {
	Battler.EnemyTypes.NONE: 0,
	Battler.EnemyTypes.GOBLIN: 10,
	Battler.EnemyTypes.FIRE_IMP: 15,
	Battler.EnemyTypes.BEAR: 20,
	Battler.EnemyTypes.ENT: 30,
	Battler.EnemyTypes.SNAKE: 40,
	Battler.EnemyTypes.ORC: 60,
	Battler.EnemyTypes.JINN: 100,
	Battler.EnemyTypes.BOSS_ONE: 500,
}


#func _calc_coin_summ(array: Array[Battler.EnemyTypes]):
	#coin_summ = 0
	#for type in array:
		#coin_summ += REWARDS.get(type) as int

# TODO: remove rewarding ???
