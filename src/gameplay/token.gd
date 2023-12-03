class_name Token
extends Resource

signal to_remove

enum Types {
	NONE = 0,
	SHIELD = 11, ATTACK = 12,
	
	FIRE = 21, STUN = 22,
}
enum ApplyMoments {
	NONE, ON_TICK, ON_GET_ATTACKED, ON_ATTACKING
}
@export var type: Types = Types.NONE
@export var icon: Texture2D
@export_range(1, 10) var lifetime_ticks: int = 1
const DISAPPEAR_IF_NOT_USED_TICKS: int = 10

var owner: Battler
var ticks_count: int


func apply_token_effect():
	match type:
		Types.FIRE:
			owner.stats.adjust_health(-1)
			adjust_tick_count(-1)
		_:
			assert(false, "Wrong token type=" + str(type))
	

func adjust_tick_count(value: int):
	ticks_count = clampi(ticks_count + value, 0, lifetime_ticks)
	if ticks_count == 0:
		owner.tokens.erase(self)
		self.free()


static func get_apply_moment(type: Types) -> ApplyMoments:
	match type:
		Types.FIRE:
			return ApplyMoments.ON_TICK
		_:
			return ApplyMoments.NONE