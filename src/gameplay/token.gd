class_name Token
extends Resource

enum Types {
	NONE = 0,
	SHIELD = 11, ATTACK = 12,
	
	FIRE = 21, STUN = 22,
}
enum ApplyMoments {
	NONE, ON_TICK, ON_GET_ATTACKED, ON_ATTACKING
}
@export var type: Types = Types.NONE
@export var icon_texture: Texture2D
@export_range(1, 10) var lifetime_ticks: int = 1

var owner: Battler
var ticks_count: int


static func create(token_type: Types, battler: Battler) -> Token:
	var token: Token
	match token_type:
		Token.Types.FIRE:
			token = Preloader.token_fire.duplicate()
		Token.Types.SHIELD:
			token = Preloader.token_shield.duplicate()
	token.owner = battler
	token.ticks_count = token.lifetime_ticks
	return token


func apply_token_effect(some_value: int = 0) -> int:
	match type:
		Types.FIRE:
			owner.stats.adjust_health(-1)
			return 1
		Types.SHIELD:
			return some_value / 2
		_:
			assert(false, "Wrong token type=" + str(type))
			return 0
	

func adjust_tick_count(value: int):
	ticks_count = clampi(ticks_count + value, 0, lifetime_ticks)
	if ticks_count == 0:
		owner.tokens.erase(self)


static func get_apply_moment(type: Types) -> ApplyMoments:
	match type:
		Types.FIRE:
			return ApplyMoments.ON_TICK
		Types.SHIELD:
			return ApplyMoments.ON_GET_ATTACKED
		_:
			return ApplyMoments.NONE
