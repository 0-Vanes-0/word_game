class_name Rune
extends Resource

enum Types {
	NONE = 0,
	EXPLOSION = 1, DARK = 2, FIRE = 3, ICE = 4, SPIKES = 5, TAUNT = 6, TESLA = 7, TORNADO = 8, WATER = 9,
}
const WORDS := {
	Types.EXPLOSION: "_",
	Types.FIRE: "промет",
	Types.DARK: "оскуро",
	Types.ICE: "фризкидо",
	Types.SPIKES: "тиерра",
	Types.TAUNT: "атронадо",
	Types.TESLA: "вольтэка",
	Types.TORNADO: "виент",
	Types.WATER: "аликид",
}
@export var type: Types = Types.NONE
@export var rune_icon: Texture2D :
	get:
		return rune_icon if rune_icon != null else Texture2D.new()


func apply_effect(action_type: Battler.ActionTypes, battler: Battler):
	match type:
		Types.TAUNT:
			battler.add_token(Token.Types.TAUNT)
		Types.FIRE:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.FIRE)
			elif action_type == Battler.ActionTypes.ALLY:
				battler.add_token(Token.Types.MIRROR)
		#Types.SPIKES:
			#if action_type == Battler.ActionTypes.ATTACK:
				#pass
			#elif action_type == Battler.ActionTypes.ALLY:
				#pass
		Types.TESLA:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.BLIND)
			elif action_type == Battler.ActionTypes.ALLY:
				battler.add_token(Token.Types.STIM)
		Types.TORNADO:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.STUN)
			elif action_type == Battler.ActionTypes.ALLY:
				battler.add_token(Token.Types.DODGE)
		Types.EXPLOSION:
			if action_type == Battler.ActionTypes.ATTACK:
				pass
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.DARK:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.LESS_DEATH_RESIST)
			elif action_type == Battler.ActionTypes.ALLY:
				battler.add_token(Token.Types.MORE_DEATH_RESIST)
		Types.ICE:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.ANTISHIELD)
			elif action_type == Battler.ActionTypes.ALLY:
				pass
		Types.WATER:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.add_token(Token.Types.ANTIATTACK)
			elif action_type == Battler.ActionTypes.ALLY:
				battler.add_token(Token.Types.HEAL_TIMED)
		_:
			assert(false, "Rune has no type")


static func create() -> Rune:
	return Rune.new()


static func get_type_string(type: Types) -> String:
	return (Types.keys()[type] as String).to_lower()
