class_name Token
extends Resource

enum Types {
	NONE = 0,
	SHIELD = 11, ATTACK = 12,

	FIRE = 21, STUN = 22,
}
enum ApplyMoments {
	NONE, ON_TURN_START, ON_GET_ATTACKED, ON_ATTACKING
}
@export var type: Types = Types.NONE
@export var apply_moment: ApplyMoments = ApplyMoments.NONE
@export var icon_texture: Texture2D
@export_range(1, 10) var base_lifetime_turns: int = 1

var owner: Battler
var lifetime_turns: int


static func create(token_type: Types, battler: Battler) -> Token:
	var token: Token
	match token_type:
		Token.Types.ATTACK:
			token = Preloader.token_attack.duplicate()
		Token.Types.FIRE:
			token = Preloader.token_fire.duplicate()
		Token.Types.SHIELD:
			token = Preloader.token_shield.duplicate()
	token.owner = battler
	token.lifetime_turns = token.base_lifetime_turns
	return token


func apply_token_effect(some_value: int = 0) -> int:
	match type:
		Types.ATTACK:
			lifetime_turns = 0
			return some_value * 2
		Types.FIRE:
			owner.stats.adjust_health(-1)
			return 1
		Types.SHIELD:
			lifetime_turns = 0
			return some_value / 2
		_:
			assert(false, "Wrong token type=" + str(type))
			return 0


func adjust_turn_count(value: int = -1):
	lifetime_turns = clampi(lifetime_turns + value, 0, base_lifetime_turns)


func is_need_delete() -> bool:
	return lifetime_turns == 0


static func get_token_name(type: Types) -> String:
	match type:
		Types.SHIELD:
			return "Щит"
		Types.ATTACK:
			return "+Урон"
		Types.FIRE:
			return "Огонь"
		Types.STUN:
			return "Оглушение"
		_:
			assert(false, "Wrong type: " + str(type))
			return ""
