class_name BattlerStats
extends Resource

signal health_changed(value: int)
signal health_depleted

@export var icon: Texture2D
@export var base_initiative: int
@export var base_health: int
@export var base_min_damage: int
@export var base_max_damage: int

var initiative: int
var health: int
var max_health: int
var min_damage: int
var max_damage: int


func _is_stats_valid() -> bool:
	return (
			icon
			and base_initiative > 0
			and base_health > 0 
			and base_min_damage <= base_max_damage and base_min_damage > 0 and base_max_damage > 0
	)


func get_resource() -> BattlerStats:
	var resoure_copy: BattlerStats = self.duplicate()
	assert(_is_stats_valid())
	resoure_copy.initiative = base_initiative
	resoure_copy.health = base_health
	resoure_copy.max_health = base_health
	resoure_copy.min_damage = base_min_damage
	resoure_copy.max_damage = base_max_damage
	return resoure_copy


func adjust_health(value: int):
	health = clampi(health + value, 0, max_health)
	health_changed.emit(health)
	if health == 0:
		health_depleted.emit()


func get_damage_value():
	return randi_range(min_damage, max_damage)

