@tool
class_name EnemyLevel
extends Resource

@export var enemy_stages: Array[EnemyLevelStage]
var level_number: int = 1

const COST_VALUES := { # TODO: recalc
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


func get_size() -> int:
	var size: int = 0
	for stage in enemy_stages:
		size += stage.enemies.size()
	return size


func get_enemy_type(i: int) -> Battler.EnemyTypes:
	return enemy_stages[i / EnemyLevelStage.STAGE_MAX_SIZE].enemies[i % EnemyLevelStage.STAGE_MAX_SIZE]
