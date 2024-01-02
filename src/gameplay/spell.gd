class_name Spell
extends Object

const MAX_CHARS: int = 25
var runes: Array[Rune]


static func create(runes: Array[Rune]) -> Spell:
	return Spell.new(runes)


func _init(runes: Array[Rune]) -> void:
	self.runes = runes.duplicate()


func apply_effects(target_battler: Battler, target_group: Array[Battler] = []):
	for rune in runes:
		if target_group.is_empty():
			_apply_rune_effect(rune, target_battler)
		else:
			for b in target_group:
				_apply_rune_effect(rune, b)


func _apply_rune_effect(rune: Rune, battler: Battler):
	match rune.type:
		Rune.Types.EXPLOSION:
			pass
		Rune.Types.DARK:
			pass
		Rune.Types.FIRE:
			battler.add_token(Token.Types.FIRE)
		Rune.Types.ICE:
			pass
		Rune.Types.SPIKES:
			pass
		Rune.Types.TAUNT:
			pass
		Rune.Types.TESLA:
			pass
		Rune.Types.TORNADO:
			pass
		Rune.Types.WATER:
			pass
		_:
			assert(false, "Rune has no type")
