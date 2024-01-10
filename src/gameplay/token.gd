class_name Token
extends Resource

enum Types {
	NONE = 0,
	SHIELD = 11, ATTACK = 12, MIRROR = 13, DODGE = 14, HEAL_TIMED = 15, STIM = 16, REACHLESS = 17, MORE_DEATH_RESIST = 18,

	FIRE = 21, STUN = 22, ANTISHIELD = 23, ANTIATTACK = 24, BLIND = 25, TAUNT = 26, LESS_DEATH_RESIST = 27,
}
enum ApplyMoments {
	NONE, ON_TURN_START, ON_GET_ATTACKED, ON_ATTACKING
}
const NAMES := {
	Types.SHIELD: "Щит",
	Types.ATTACK: "+Урон",
	Types.MIRROR: "",
	Types.DODGE: "",
	Types.HEAL_TIMED: "",
	Types.STIM: "",
	Types.REACHLESS: "",
	Types.MORE_DEATH_RESIST: "",
	
	Types.LESS_DEATH_RESIST: "",
	Types.FIRE: "Огонь",
	Types.STUN: "Оглушение",
	Types.ANTIATTACK: "",
	Types.ANTISHIELD: "",
	Types.BLIND: "",
	Types.TAUNT: "",
}
@export var type: Types = Types.NONE
@export var apply_moment: ApplyMoments = ApplyMoments.NONE
@export var icon_texture: Texture2D
@export var is_hidden: bool
@export_range(1, 10) var base_lifetime_turns: int = 1


var owner: Battler
var lifetime_turns: int


static func create(token_type: Types, battler: Battler) -> Token:
	var token: Token
	match token_type:
		Types.SHIELD:
			token = Preloader.token_shield.duplicate()
		Types.ATTACK:
			token = Preloader.token_attack.duplicate()
		Types.MIRROR:
			token = Preloader.token_mirror.duplicate()
		Types.DODGE:
			token = Preloader.token_dodge.duplicate()
		Types.HEAL_TIMED:
			token = Preloader.token_heal_timed.duplicate()
		Types.STIM:
			token = Preloader.token_stim.duplicate()
		Types.REACHLESS:
			token = Preloader.token_reachless.duplicate()
		Types.MORE_DEATH_RESIST:
			token = Preloader.token_less_death_resist.duplicate()
		
		Types.LESS_DEATH_RESIST:
			token = Preloader.token_less_death_resist.duplicate()
		Types.FIRE:
			token = Preloader.token_fire.duplicate()
		Types.STUN:
			token = Preloader.token_stun.duplicate()
		Types.ANTIATTACK:
			token = Preloader.token_antiattack.duplicate()
		Types.ANTISHIELD:
			token = Preloader.token_antishield.duplicate()
		Types.BLIND:
			token = Preloader.token_blind.duplicate()
		Types.TAUNT:
			token = Preloader.token_taunt.duplicate()
		
		_:
			assert(false, "Wrong token type=" + str(token_type))
	token.owner = battler
	token.lifetime_turns = token.base_lifetime_turns
	return token


func apply_token_effect(some_value: int = 0) -> int:
	match type:
		Types.SHIELD:
			lifetime_turns = 0
			return some_value / 2
		Types.ATTACK:
			lifetime_turns = 0
			return some_value * 2
		Types.MIRROR:
			return 0
		Types.DODGE:
			return 0
		Types.HEAL_TIMED:
			return 0
		Types.STIM:
			return 0
		Types.REACHLESS:
			return 0
		Types.MORE_DEATH_RESIST:
			return 0
		
		Types.LESS_DEATH_RESIST:
			return 0
		Types.MIRROR:
			return 0
		Types.FIRE:
			owner.stats.adjust_health(-1)
			return 1
		Types.STUN:
			return 0
		Types.ANTIATTACK:
			return 0
		Types.ANTISHIELD:
			return 0
		Types.BLIND:
			return 0
		Types.TAUNT:
			return 0
		
		_:
			assert(false, "Wrong token type=" + str(type))
			return 0


func adjust_turn_count(value: int = -1):
	lifetime_turns = clampi(lifetime_turns + value, 0, base_lifetime_turns)


func is_need_delete() -> bool:
	return lifetime_turns == 0


static func get_token_name(type: Types) -> String:
	return NAMES[type]
