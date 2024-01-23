class_name Spell
extends Object

const MAX_CHARS: int = 25
var caster: Battler
var runes: Array[Rune]
var shifted_turns: int = 1


static func create(caster: Battler, runes: Array[Rune]) -> Spell:
	return Spell.new(caster, runes)


func _init(caster: Battler, runes: Array[Rune]) -> void:
	self.runes = runes.duplicate()
	self.caster = caster


func apply_effects(action_type: Battler.ActionTypes, target_battler: Battler, target_group: Array[Battler] = []):
	for rune in runes:
		if rune.type == Rune.Types.TAUNT:
			rune.apply_effect(action_type, caster)
			continue
		
		if target_group.is_empty():
			rune.apply_effect(action_type, target_battler)
		else:
			for b in target_group:
				rune.apply_effect(action_type, b)
	
	shifted_turns = clampi(runes.size(), 1, 3)
