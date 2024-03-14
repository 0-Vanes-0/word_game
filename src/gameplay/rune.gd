class_name Rune
extends Resource

enum Types {
	NONE = 0,
	EXPLOSION = 1, DARK = 2, FIRE = 3, ICE = 4, SPIKES = 5, TAUNT = 6, TESLA = 7, TORNADO = 8, WATER = 9,
}
const WORDS := {
	Types.EXPLOSION: "кареакто",
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
			battler.token_handler.add_token(Token.Types.TAUNT)
		
		Types.FIRE:
			if action_type == Battler.ActionTypes.ATTACK and battler.resist_handler.provoke_resist(Resist.Types.FIRE) == false:
				battler.token_handler.add_token(Token.Types.FIRE)
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.MIRROR)
		
		#Types.SPIKES:
			#if action_type == Battler.ActionTypes.ATTACK:
				#pass
			#elif action_type == Battler.ActionTypes.ALLY:
				#pass
		
		Types.TESLA:
			if action_type == Battler.ActionTypes.ATTACK and battler.resist_handler.provoke_resist(Resist.Types.TESLA) == false:
				battler.token_handler.add_token(Token.Types.BLIND)
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.STIM)
		
		Types.TORNADO:
			if action_type == Battler.ActionTypes.ATTACK and battler.resist_handler.provoke_resist(Resist.Types.TORNADO) == false:
				battler.token_handler.add_token(Token.Types.STUN)
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.DODGE)
		
		Types.EXPLOSION:
			if action_type == Battler.ActionTypes.ATTACK:
				var pos_types: Array[Token.Types] = []
				for t in battler.tokens:
					if t.type in Token.POSITIVE_TYPES and not t.type in pos_types:
						pos_types.append(t.type)
				if not pos_types.is_empty():
					var picked: Token.Types = pos_types.pick_random()
					for t in battler.tokens:
						if t.type == picked:
							t.queue_outofturns()
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.REACHLESS)
		
		Types.DARK:
			if action_type == Battler.ActionTypes.ATTACK:
				battler.token_handler.add_token(Token.Types.LESS_DEATH_RESIST)
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.MORE_DEATH_RESIST)
		
		Types.ICE:
			if action_type == Battler.ActionTypes.ATTACK and battler.resist_handler.provoke_resist(Resist.Types.ICE) == false:
				battler.token_handler.add_token(Token.Types.ANTISHIELD)
			
			elif action_type == Battler.ActionTypes.ALLY:
				var neg_types: Array[Token.Types] = []
				for t in battler.tokens:
					if t.type in Token.NEGATIVE_TYPES and not t.type in neg_types:
						neg_types.append(t.type)
				if not neg_types.is_empty():
					var picked: Token.Types = neg_types.pick_random()
					for t in battler.tokens:
						if t.type == picked:
							t.queue_outofturns()
		
		Types.WATER:
			if action_type == Battler.ActionTypes.ATTACK and battler.resist_handler.provoke_resist(Resist.Types.WATER) == false:
				battler.token_handler.add_token(Token.Types.ANTIATTACK)
			
			elif action_type == Battler.ActionTypes.ALLY:
				battler.token_handler.add_token(Token.Types.HEAL_TIMED)
		
		_:
			assert(false, "Rune has no type")


static func create() -> Rune:
	return Rune.new()


static func get_type_string(type: Types) -> String:
	return (Types.keys()[type] as String).to_lower()
