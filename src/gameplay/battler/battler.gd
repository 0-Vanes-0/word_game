class_name Battler
extends Node2D

signal clicked
signal hold_started
signal hold_stopped
signal died
signal action_successed(on_battler: Battler)

enum Types {
	NONE = 0,
	HERO_KNIGHT = 11, HERO_ROBBER = 12, HERO_MAGE = 13,
	
	ENEMY_GOBLIN = 21, ENEMY_FIRE_IMP = 22, ENEMY_BEAR = 23, ENEMY_ENT = 24, ENEMY_SNAKE = 25, ENEMY_ORC = 26, ENEMY_JINN = 27, BOSS_ONE = 28
}
enum ActionTypes {
	NONE, ATTACK, ALLY
}
const HEROES: Array[Types] = [Types.HERO_KNIGHT, Types.HERO_ROBBER, Types.HERO_MAGE]
const ENEMIES: Array[Types] = [Types.ENEMY_GOBLIN, Types.ENEMY_FIRE_IMP, Types.ENEMY_BEAR, Types.ENEMY_ENT, Types.ENEMY_SNAKE, Types.ENEMY_ORC, Types.ENEMY_JINN, Types.BOSS_ONE]

var type: Types
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

var sprite: AnimatedSprite2D
var selection_hover: Sprite2D
var selection: Sprite2D
var size_area: Area2D
var coll_shape: CollisionShape2D
var health_bar: MyProgressBar
var tokens_container: HFlowContainer
var coin_counter: CenterContainer
var token_handler: TokenHandler
var anim_handler: BattlerAnimHandler
var resist_handler: ResistHandler


static func create(type: Types, stats: BattlerStats, index: int) -> Battler:
	return Battler.new(type, stats, index)


#region Init
func _init(type: Types, stats: BattlerStats, index: int) -> void:
	self.type = type
	self.stats = stats.get_resource()
	self.stats.health_changed.connect(_on_health_changed)
	self.stats.health_depleted.connect(_on_health_depleted)
	if self.stats is PlayerBattlerStats:
		self.stats.assign_level(Global.get_player_level(type))
	
	self.index = index
	
	token_handler = TokenHandler.new()
	self.add_child(token_handler)
	
	anim_handler = BattlerAnimHandler.new()
	self.add_child(anim_handler)
	
	resist_handler = ResistHandler.new()
	self.add_child(resist_handler)
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Battler._get_sprite_frames(type)
	sprite.offset = Battler._get_offset(type)
	sprite.scale = (
			Vector2(Battler._get_scale_x(type), 1) * 1.5
			if type == Types.BOSS_ONE
			else Vector2(Battler._get_scale_x(type), 1) * 2.0
	)
	sprite.name = "BattlerSprite"
	self.add_child(sprite)
	
	selection = Sprite2D.new()
	selection.texture = Preloader.texture_selection
	selection.offset = Vector2.DOWN * selection.texture.get_height() / 2
	selection.scale = Vector2.ONE * 2.5
	selection.name = "SelectionSprite"
	self.add_child(selection)
	selection.hide()
	
	selection_hover = Sprite2D.new()
	selection_hover.texture = Preloader.texture_selection_hover
	selection_hover.offset = Vector2.UP * (selection_hover.texture.get_height() / 2 - selection.texture.get_height())
	selection_hover.scale = Vector2.ONE * 2.5
	selection_hover.name = "SelectionHoverSprite"
	self.add_child(selection_hover)
	selection.move_to_front()
	selection_hover.hide()
	
	size_area = Area2D.new()
	coll_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Global.CHARACTER_SIZE
	coll_shape.shape = shape
	coll_shape.position = Vector2.UP * Global.CHARACTER_SIZE.y / 2
	size_area.add_child(coll_shape)
	size_area.name = "SizeArea"
	self.add_child(size_area)
	size_area.input_event.connect(_on_pressed)
	
	health_bar = MyProgressBar.create(MyProgressBar.Colors.RED, MyProgressBar.ValueDisplayType.FRACTION)
	health_bar.name = "HealthBar"
	self.add_child(health_bar)
	health_bar.position = Vector2.LEFT * health_bar.custom_minimum_size.x / 2
	health_bar.min_value = 0
	health_bar.max_value = self.stats.max_health
	health_bar.set_bar_value(health_bar.max_value)
	
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.custom_minimum_size = Global.CHARACTER_SIZE
	vbox.name = "TokensContainer"
	self.add_child(vbox)
	vbox.position = Vector2(- Global.CHARACTER_SIZE.x / 2, - Global.CHARACTER_SIZE.y * 2)
	tokens_container = HFlowContainer.new()
	tokens_container.alignment = FlowContainer.ALIGNMENT_CENTER
	tokens_container.z_index = 999
	vbox.add_child(tokens_container)
	
	coin_counter = CenterContainer.new()
	self.add_child(coin_counter)
	var coin_label := Preloader.icon_label.instantiate() as IconLabel
	coin_label.set_icon(Preloader.texture_coin, IconLabel.Sizes.x16)
	coin_label.set_text("")
	coin_label.set_text_color(Color.GOLD)
	coin_counter.add_child(coin_label)
	
	coin_counter.position = Vector2.LEFT * Global.CHARACTER_SIZE.x / 2 + Vector2.DOWN * 30
	coin_counter.custom_minimum_size.x = Global.CHARACTER_SIZE.x
	coin_counter.hide()
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


func set_coin_counter(value: int):
	coin_counter.show()
	var coin_label := coin_counter.get_child(0) as IconLabel
	coin_label.set_text(value)


#region Actions
func do_attack_action(target_battler: Battler, target_group: Array[Battler] = [], on_attack_success_func := Callable(), is_first_call := true): # TODO: bad code -> both target_battler and target_group :/
	action_value = int(stats.generate_damage_value())
	damage_modifier = 0
	is_stimed = false
	miss_chance = 0
	
	self.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_ATTACKING)
	
	if target_group.is_empty():
		_perform_attack(target_battler, on_attack_success_func)
	else:
		for b in target_group:
			damage_modifier = 0
			_perform_attack(b, on_attack_success_func)
	
	if type == Types.HERO_ROBBER and is_first_call and target_battler.is_alive:
		await get_tree().create_timer(0.25).timeout
		do_attack_action(target_battler, [], Callable(), false)
	else:
		self.token_handler.check_tokens()
		if target_group.is_empty():
			target_battler.token_handler.check_tokens()
		else:
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


func do_ally_action(target_battler: Battler, target_group: Array[Battler] = []): # TODO: bad code -> both target_battler and target_group :/
	action_value = 0
	
	if type == Types.HERO_KNIGHT:
		target_battler.token_handler.add_token(Token.Types.SHIELD, stats.ally_action_value)
	
	elif type == Types.HERO_ROBBER:
		target_battler.token_handler.add_token(Token.Types.ATTACK, stats.ally_action_value)
	
	elif type == Types.HERO_MAGE:
		action_value = int(target_battler.stats.max_health * (stats.ally_action_value / 100.0))
		target_battler.stats.adjust_health(action_value)
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


func _on_health_depleted():
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
static func get_start_stats(type: Types) -> BattlerStats:
	match type:
		Types.HERO_KNIGHT:
			return Preloader.stats_knight
		Types.HERO_ROBBER:
			return Preloader.stats_robber
		Types.HERO_MAGE:
			return Preloader.stats_mage
		Types.ENEMY_GOBLIN:
			return Preloader.stats_goblin
		Types.ENEMY_FIRE_IMP:
			return Preloader.stats_fire_imp
		Types.ENEMY_BEAR:
			return Preloader.stats_bear
		Types.ENEMY_ENT:
			return Preloader.stats_ent
		Types.ENEMY_SNAKE:
			return Preloader.stats_snake
		Types.ENEMY_ORC:
			return Preloader.stats_orc
		Types.ENEMY_JINN:
			return Preloader.stats_jinn
		Types.BOSS_ONE:
			return Preloader.stats_boss_one
		
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func _get_sprite_frames(type: Types) -> MySpriteFrames:
	match type:
		Types.HERO_KNIGHT:
			return Preloader.sprite_frames_knight
		Types.HERO_ROBBER:
			return Preloader.sprite_frames_robber
		Types.HERO_MAGE:
			return Preloader.sprite_frames_mage
		Types.ENEMY_GOBLIN:
			return Preloader.sprite_frames_goblin
		Types.ENEMY_FIRE_IMP:
			return Preloader.sprite_frames_fire_imp
		Types.ENEMY_BEAR:
			return Preloader.sprite_frames_bear
		Types.ENEMY_ENT:
			return Preloader.sprite_frames_ent
		Types.ENEMY_SNAKE:
			return Preloader.sprite_frames_snake
		Types.ENEMY_ORC:
			return Preloader.sprite_frames_orc
		Types.ENEMY_JINN:
			return Preloader.sprite_frames_jinn
		Types.BOSS_ONE:
			return Preloader.sprite_frames_boss_one
		
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func _get_offset(type: Types) -> Vector2:
	return _get_sprite_frames(type).offset


static func _get_scale_x(type: Types) -> int:
	if type in HEROES:
		return 1
	elif type in ENEMIES:
		return -1
	else:
		assert(false, "Wrong type: " + str(type))
		return 0
#endregion
