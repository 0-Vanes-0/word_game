class_name Spell
extends Object

const MAX_CHARS: int = 25
var runes: Array[Rune]


static func create(runes: Array[Rune]) -> Spell:
	return Spell.new(runes)


func _init(runes: Array[Rune]) -> void:
	self.runes = runes.duplicate()


func apply_effects(action_type: Battler.ActionTypes, target_battler: Battler, target_group: Array[Battler] = []):
	for rune in runes:
		if target_group.is_empty():
			rune.apply_effect(action_type, target_battler)
		else:
			for b in target_group:
				rune.apply_effect(action_type, b)
