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


func apply_effect(action_type: Battler.ActionTypes, battler: Battler):
	match type:
		Types.TAUNT:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.FIRE:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.FIRE)
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.SPIKES:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.TESLA:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.TORNADO:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.EXPLOSION:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.DARK:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.ICE:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.WATER:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		_:
			assert(false, "Rune has no type")


static func create() -> Rune:
	return Rune.new()


static func get_type_string(type: Types) -> String:
	return (Types.keys()[type] as String).to_lower()
