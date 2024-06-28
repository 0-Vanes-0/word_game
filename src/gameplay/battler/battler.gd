class_name Battler
extends Node2D

signal clicked
signal hold_started
signal hold_stopped
signal died

enum HeroTypes {
	NONE = -1, KNIGHT = 11, ROBBER = 12, MAGE = 13,
}
enum EnemyTypes {
	NONE = -1, GOBLIN = 21, FIRE_IMP = 22, BEAR = 23, ENT = 24, SNAKE = 25, ORC = 26, JINN = 27, BOSS_ONE = 28
}
enum ActionTypes {
	NONE, ATTACK, ALLY
}
static var HEROES: Array = HeroTypes.values()
static var ENEMIES: Array = EnemyTypes.values()

var type: int # HeroTypes + EnemyTypes
var stats: BattlerStats
var index: int = -1
var is_alive: bool = true
var is_about_to_die: bool = false
var tokens: Array[Token] = []

var tween_dying: Tween
var action_value: int = 0
var damage_modifier: int = 0
var defense_modifier: int = 0
var mirror_modifier: int = 0
var dodge_chance: int = 0
var miss_chance: int = 0
var pre_damage: int = 0
var pre_heal: int = 0
var stun_turns: int = 0
var is_stimed := false

@export_group("Required Children")
@export var sprite: AnimatedSprite2D

@export var uis: Node2D
@export var selection_hover: Sprite2D
@export var selection: Sprite2D
@export var health_bar: MyProgressBar
@export var tokens_container: HFlowContainer
var coin_counter: CenterContainer

@export var size_area: Area2D
var coll_shape: CollisionShape2D

@export var token_handler: TokenHandler
@export var anim_handler: BattlerAnimHandler
@export var resist_handler: ResistHandler


static func create(type: int, stats: BattlerStats, index: int) -> Battler:
	var battler := Preloader.battler_template.instantiate() as Battler
	return battler.initialize(type, stats, index)


#region Init
func initialize(type: int, stats: BattlerStats, index: int) -> Battler:
	assert(sprite and uis and selection_hover and selection and health_bar and tokens_container and size_area and token_handler and anim_handler and resist_handler)
	assert(type in HEROES or type in ENEMIES)
	self.type = type
	self.stats = stats.get_resource()
	self.stats.health_changed.connect(_on_health_changed)
	self.stats.health_depleted.connect(_on_health_depleted)
	if self.stats is PlayerBattlerStats:
		self.stats.assign_level(Global.get_player_level(type)) # TODO: make enemy assign level as well ???
	
	self.index = index
	
	sprite.sprite_frames = Battler._get_sprite_frames(type)
	sprite.offset = Battler._get_offset(type)
	sprite.scale = (
			Vector2(Battler._get_scale_x(type), 1) * 2.0
			if type != EnemyTypes.BOSS_ONE
			else Vector2(Battler._get_scale_x(type), 1) * 1.5
	)
	
	selection.hide()
	selection_hover.hide()
	
	coll_shape = size_area.get_child(0) as CollisionShape2D
	size_area.input_event.connect(_on_pressed)
	
	health_bar.min_value = 0
	health_bar.max_value = self.stats.max_health
	health_bar.set_bar_value(health_bar.max_value)
	
	return self
#endregion


func _ready() -> void:
	var frames_count: int = sprite.sprite_frames.get_frame_count(BattlerAnimHandler.Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
	anim_handler.anim_idle(start_frame)


const TAP_MAX_TIME := 0.2; var timer := TAP_MAX_TIME
var is_finger_on := false; var is_holding := false

func _on_pressed(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_finger_on = true
			timer = 0.0
		else:
			is_finger_on = false
			is_holding = false
			if timer < TAP_MAX_TIME:
				clicked.emit()
			else:
				hold_stopped.emit()
	
	elif event is InputEventScreenDrag and is_holding:
		is_finger_on = false
		is_holding = false
		hold_stopped.emit()


func _physics_process(delta: float) -> void:
	if timer < TAP_MAX_TIME:
		timer += delta
	else:
		timer = TAP_MAX_TIME
		if is_finger_on and not is_holding:
			is_holding = true
			hold_started.emit()


func set_area_inputable(is_inputable: bool):
	coll_shape.disabled = not is_inputable


#region Actions
func do_attack_action(target_group: Array[Battler], on_attack_success_func := Callable()):
	action_value = int(stats.generate_damage_value())
	damage_modifier = 0
	is_stimed = false
	miss_chance = 0
	
	self.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_ATTACKING)
	
	for b in target_group:
		_perform_attack(b, on_attack_success_func)
	
	if type == HeroTypes.ROBBER:
		await get_tree().create_timer(0.25).timeout
		do_attack_action(target_group, Callable()) # TODO: what here?
	else:
		self.token_handler.check_tokens()
		for b in target_group:
			b.token_handler.check_tokens()


func _perform_attack(target_battler: Battler, on_attack_success_func: Callable):
	target_battler.defense_modifier = 0
	target_battler.mirror_modifier = 0
	target_battler.dodge_chance = 0
	
	target_battler.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_GET_ATTACKED)
	var is_avoid := randf() < 1.0 - calc_hit_chance(target_battler)
	
	if is_avoid:
		target_battler.anim_handler.anim_value_label(BattlerAnimHandler.TextTypes.ATTACK, str("ПРОМАХ"))
	else:
		self.token_handler.apply_tokens(Token.ApplyMoments.ON_ATTACKING)
		target_battler.token_handler.apply_tokens(Token.ApplyMoments.ON_GET_ATTACKED)
		var result := calc_damage_value(action_value, target_battler)
		target_battler.stats.adjust_health(- result)
		
		if not on_attack_success_func.is_null():
			on_attack_success_func.call()
		
		if target_battler.mirror_modifier > 0:
			await get_tree().create_timer(0.25).timeout
			self.stats.adjust_health(- ceili(result * target_battler.mirror_modifier / 100.0) )


func calc_damage_value(value: int, target_battler: Battler) -> int:
	return roundi( value * (1 + damage_modifier / 100.0) * (1 - target_battler.defense_modifier / 100.0) )


func calc_hit_chance(target_battler: Battler) -> float:
	return (1.0 - miss_chance / 100.0) * (1.0 - target_battler.dodge_chance / 100.0)


func do_ally_action(target_group: Array[Battler]):
	action_value = 0
	
	if type == HeroTypes.KNIGHT:
		for b in target_group:
			b.token_handler.add_token(Token.Types.SHIELD, stats.ally_action_value)
	
	elif type == HeroTypes.ROBBER:
		for b in target_group:
			b.token_handler.add_token(Token.Types.ATTACK, stats.ally_action_value)
	
	elif type == HeroTypes.MAGE:
		for b in target_group:
			action_value = int(b.stats.max_health * (stats.ally_action_value / 100.0))
			b.stats.adjust_health(action_value)
#endregion

#region Health signals
func _on_health_changed(value: int, delta: int):
	health_bar.set_bar_value(value)
	if value > 0:
		if is_about_to_die:
			anim_handler.anim_and_set_about_to_die(false)
		else:
			var text_type := (
					BattlerAnimHandler.TextTypes.ATTACK if delta < 0
					else BattlerAnimHandler.TextTypes.ALLY if delta > 0
					else BattlerAnimHandler.TextTypes.NONE
			)
			anim_handler.anim_value_label(text_type, str(delta))


func _on_health_depleted() -> void:
	if resist_handler.get_resist(Resist.Types.DEATHS_DOOR) != null:
		if not is_about_to_die:
			anim_handler.anim_value_label(BattlerAnimHandler.TextTypes.ATTACK, str("ПРИ\nСМЕРТИ"))
			anim_handler.anim_and_set_about_to_die(true)
			return
		elif is_alive and resist_handler.provoke_resist(Resist.Types.DEATHS_DOOR):
			return
	
	anim_handler.anim_value_label(BattlerAnimHandler.TextTypes.ATTACK, str("СМЕРТЬ"))
	anim_handler.anim_and_set_about_to_die(false)
	is_alive = false
	health_bar.hide()
	tokens_container.hide()
	tokens.clear()
	anim_handler.anim_die()
	died.emit()
#endregion

#region Static functions
static func get_start_stats(type: int) -> BattlerStats:
	match type:
		HeroTypes.KNIGHT:
			return Preloader.stats_knight
		HeroTypes.ROBBER:
			return Preloader.stats_robber
		HeroTypes.MAGE:
			return Preloader.stats_mage
		EnemyTypes.GOBLIN:
			return Preloader.stats_goblin
		EnemyTypes.FIRE_IMP:
			return Preloader.stats_fire_imp
		EnemyTypes.BEAR:
			return Preloader.stats_bear
		EnemyTypes.ENT:
			return Preloader.stats_ent
		EnemyTypes.SNAKE:
			return Preloader.stats_snake
		EnemyTypes.ORC:
			return Preloader.stats_orc
		EnemyTypes.JINN:
			return Preloader.stats_jinn
		EnemyTypes.BOSS_ONE:
			return Preloader.stats_boss_one
		
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func _get_sprite_frames(type: int) -> MySpriteFrames:
	match type:
		HeroTypes.KNIGHT:
			return Preloader.sprite_frames_knight
		HeroTypes.ROBBER:
			return Preloader.sprite_frames_robber
		HeroTypes.MAGE:
			return Preloader.sprite_frames_mage
		EnemyTypes.GOBLIN:
			return Preloader.sprite_frames_goblin
		EnemyTypes.FIRE_IMP:
			return Preloader.sprite_frames_fire_imp
		EnemyTypes.BEAR:
			return Preloader.sprite_frames_bear
		EnemyTypes.ENT:
			return Preloader.sprite_frames_ent
		EnemyTypes.SNAKE:
			return Preloader.sprite_frames_snake
		EnemyTypes.ORC:
			return Preloader.sprite_frames_orc
		EnemyTypes.JINN:
			return Preloader.sprite_frames_jinn
		EnemyTypes.BOSS_ONE:
			return Preloader.sprite_frames_boss_one
		
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func _get_offset(type: int) -> Vector2:
	return _get_sprite_frames(type).offset


static func _get_scale_x(type: int) -> int:
	if type in HeroTypes.values():
		return 1
	elif type in EnemyTypes.values():
		return -1
	else:
		assert(false, "Wrong type: " + str(type))
		return 0
#endregion
