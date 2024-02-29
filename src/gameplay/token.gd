class_name Token
extends Resource

enum Types {
	NONE = 0,
	SHIELD = 11, ATTACK = 12, MIRROR = 13, DODGE = 14, HEAL_TIMED = 15, STIM = 16, REACHLESS = 17, MORE_DEATH_RESIST = 18,
	
	FIRE = 21, STUN = 22, ANTISHIELD = 23, ANTIATTACK = 24, BLIND = 25, TAUNT = 26, LESS_DEATH_RESIST = 27,
}
const POSITIVE_TYPES: Array[Types] = [Types.SHIELD, Types.ATTACK, Types.DODGE, Types.HEAL_TIMED, Types.STIM, Types.REACHLESS]
const NEGATIVE_TYPES: Array[Types] = [Types.FIRE, Types.STUN, Types.ANTISHIELD, Types.ANTIATTACK, Types.BLIND, Types.TAUNT]
enum ApplyMoments {
	NONE, ON_TURN_START, ON_GET_ATTACKED, ON_ATTACKING, BEFORE_GET_ATTACKED, BEFORE_ATTACKING
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
@export_range(0, 4) var max_amount: int = 3

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
			battler.stats.get_deaths_door_resist().adjust_value(10)
		
		Types.LESS_DEATH_RESIST:
			token = Preloader.token_less_death_resist.duplicate()
			battler.stats.get_deaths_door_resist().adjust_value(-10)
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


func apply_token_effect(should_be_spent := true):
	if should_be_spent and (
			apply_moment == ApplyMoments.ON_ATTACKING 
			or apply_moment == ApplyMoments.ON_GET_ATTACKED 
			or apply_moment == ApplyMoments.BEFORE_GET_ATTACKED
			or apply_moment == ApplyMoments.BEFORE_ATTACKING
		):
		queue_delete()
	
	match type:
		Types.SHIELD:
			owner.defense_modifier += 50
			print_debug("defense_modifier=", owner.defense_modifier)
		Types.ATTACK:
			owner.damage_modifier += 50
			print_debug("damage_modifier=", owner.damage_modifier)
		Types.MIRROR:
			owner.mirror_modifier += 50
			print_debug("mirror_modifier=", owner.mirror_modifier)
		Types.DODGE:
			owner.dodge_chance = 50
			print_debug("Can dodge!")
		Types.HEAL_TIMED:
			owner.pre_heal += 10
			print_debug("Healed!")
		Types.STIM:
			owner.action_value = owner.stats.max_damage
			owner.is_stimed = true
			print_debug("Stimulated!")
		Types.REACHLESS:
			pass
		Types.MORE_DEATH_RESIST:
			pass # TODO 10
		
		Types.LESS_DEATH_RESIST:
			pass # TODO 10
		Types.FIRE:
			owner.pre_damage += 2
			print_debug("Burnt!")
		Types.STUN:
			owner.stun_turns += 1
		Types.ANTIATTACK:
			owner.damage_modifier -= 50
			print_debug("damage_modifier=", owner.damage_modifier)
		Types.ANTISHIELD:
			owner.defense_modifier -= 50
			print_debug("defense_modifier=", owner.defense_modifier)
		Types.BLIND:
			owner.miss_chance = 50
			print_debug("Can miss!")
		Types.TAUNT:
			pass
		
		_:
			assert(false, "Wrong token type=" + str(type))


func adjust_turn_count(value: int = -1):
	lifetime_turns = clampi(lifetime_turns + value, 0, base_lifetime_turns)


func queue_delete():
	lifetime_turns = 0


func is_need_delete() -> bool:
	if type == Types.MORE_DEATH_RESIST:
		owner.stats.get_deaths_door_resist().adjust_value(-10 * int(lifetime_turns == 0))
	elif type == Types.LESS_DEATH_RESIST:
		owner.stats.get_deaths_door_resist().adjust_value(10 * int(lifetime_turns == 0))
	return lifetime_turns == 0


static func get_token_name(type: Types) -> String:
	return NAMES[type]


static func get_max_amount(type: Types) -> int:
	match type:
		Types.SHIELD:
			return Preloader.token_shield.max_amount
		Types.ATTACK:
			return Preloader.token_attack.max_amount
		Types.MIRROR:
			return Preloader.token_mirror.max_amount
		Types.DODGE:
			return Preloader.token_dodge.max_amount
		Types.HEAL_TIMED:
			return Preloader.token_heal_timed.max_amount
		Types.STIM:
			return Preloader.token_stim.max_amount
		Types.REACHLESS:
			return Preloader.token_reachless.max_amount
		Types.MORE_DEATH_RESIST:
			return Preloader.token_less_death_resist.max_amount
		
		Types.LESS_DEATH_RESIST:
			return Preloader.token_less_death_resist.max_amount
		Types.FIRE:
			return Preloader.token_fire.max_amount
		Types.STUN:
			return Preloader.token_stun.max_amount
		Types.ANTIATTACK:
			return Preloader.token_antiattack.max_amount
		Types.ANTISHIELD:
			return Preloader.token_antishield.max_amount
		Types.BLIND:
			return Preloader.token_blind.max_amount
		Types.TAUNT:
			return Preloader.token_taunt.max_amount
		
		_:
			assert(false, "Wrong token type=" + str(type))
			return -1
