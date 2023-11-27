class_name Rune
extends Resource

enum Types {
	NONE = 0,
	COMET = 1, FIRE = 2, STUN = 3, ICE = 4, DARK = 5,
}
const STRINGS := {
	Types.NONE: "none",
	Types.COMET: "comet",
	Types.FIRE: "fire",
	Types.STUN: "stun",
	Types.ICE: "ice",
	Types.DARK: "dark",
}
const WORDS := {
	Types.COMET: "морадо",
	Types.FIRE: "фуего",
	Types.STUN: "атронадо",
	Types.ICE: "фрио",
	Types.DARK: "оскуро",
}
@export var type: Types = Types.NONE
@export var rune_icon: Texture2D :
	get:
		if rune_icon == null:
			print_debug("rune icon is null! type: ", type)
		return rune_icon if rune_icon != null else Texture2D.new()


static func create() -> Rune:
	return Rune.new()


func _init() -> void:
	super()
