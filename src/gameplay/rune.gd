class_name Rune
extends Resource

enum Types {
	NONE = 0,
	EXPLOSION = 1, DARK = 2, FIRE = 3, ICE = 4, SPIKES = 5, TAUNT = 6, TESLA = 7, TORNADO = 8, WATER = 9,
}
const WORDS := {
	Types.EXPLOSION: "морадо",
	Types.DARK: "оскуро",
	Types.FIRE: "фуего",
	Types.ICE: "фрио",
	Types.SPIKES: "тиерра",
	Types.TAUNT: "атронадо",
	Types.TESLA: "триси",
	Types.TORNADO: "виенто",
	Types.WATER: "агуа",
}
@export var type: Types = Types.NONE
@export var rune_icon: Texture2D :
	get:
		return rune_icon if rune_icon != null else Texture2D.new()


static func create() -> Rune:
	return Rune.new()


static func get_type_string(type: Types) -> String:
	return (Types.keys()[type] as String).to_lower()
