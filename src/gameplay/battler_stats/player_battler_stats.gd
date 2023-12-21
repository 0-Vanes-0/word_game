class_name PlayerBattlerStats
extends BattlerStats

@export var runes: Array[Rune]
@export var health_up_per_level: int
@export var damage_up_per_level: int
var level: int = 1


func _is_stats_valid() -> bool:
	return super() and (true
			#and 2 <= runes.size() and runes.size() <= 4
			and health_up_per_level > 0
			and damage_up_per_level > 0
	)


func get_resource() -> BattlerStats:
	var resource_copy = super()
	return resource_copy


func assign_level(level: int) -> PlayerBattlerStats:
	self.level = level
	self.max_health = base_health + get_health_addition(level)
	self.health = self.max_health
	self.max_damage = base_max_damage + get_damage_addition(level)
	return self


func get_health_addition(level: int) -> int:
	return (level - 1) * health_up_per_level


func get_damage_addition(level: int) -> int:
	return (level - 1) * damage_up_per_level
