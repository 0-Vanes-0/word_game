class_name EnemyLeveling
extends Resource

@export_range(1, 100) var level_number: int = 1
@export var enemies: Array[Battler.Types] = [ Battler.Types.NONE, Battler.Types.NONE, Battler.Types.NONE ]
