class_name BattlerStats
extends Resource

signal health_depleted

@export var base_health: int
@export var base_damage: int

var health: int
var damage: int


func _init() -> void:
	health = base_health
	damage = base_damage


func set_health(value: int):
	health = clampi(value, 0, base_health)
	if health == 0:
		health_depleted.emit()
