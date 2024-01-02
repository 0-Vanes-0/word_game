class_name Spell
extends Object

const MAX_CHARS: int = 25
var runes: Array[Rune]


static func create(runes: Array[Rune]) -> Spell:
	return Spell.new(runes)


func _init(runes: Array[Rune]) -> void:
	pass
