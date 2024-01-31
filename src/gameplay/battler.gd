class_name Battler
extends Node2D

signal clicked
signal hold_started
signal hold_stopped
signal died

enum Types {
	NONE = 0,
	HERO_KNIGHT = 11, HERO_ROBBER = 12, HERO_MAGE = 13,
	
	ENEMY_GOBLIN = 21, ENEMY_FIRE_IMP = 22, ENEMY_BEAR = 23, ENEMY_ENT = 24
}
enum ActionTypes {
	NONE, ATTACK, ALLY
}
const HEROES: Array[Types] = [Types.HERO_KNIGHT, Types.HERO_ROBBER, Types.HERO_MAGE]
const MOBS: Array[Types] = [Types.ENEMY_GOBLIN, Types.ENEMY_FIRE_IMP, Types.ENEMY_BEAR, Types.ENEMY_ENT]
const Animations := {
	IDLE = "idle",
	PREPARE_ATTACK = "prepare_attack",
	PREPARE_SELF = "prepare_self",
	PREPARE_ALLY = "prepare_ally",
	ACTION_ATTACK = "action_attack",
	ACTION_SELF = "action_self",
	ACTION_ALLY = "action_ally",
	HURT = "hurt",
	BUFF = "buff",
	DIE = "die",
}

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
var tokens_container: VBoxContainer
var token_handler: TokenHandler


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
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Battler.get_sprite_frames(type)
	sprite.offset = Battler.get_offset(type)
	sprite.scale = Vector2(Battler.get_scale_x(type), 1) * 2.0
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
	
	tokens_container = VBoxContainer.new()
	tokens_container.alignment = BoxContainer.ALIGNMENT_END
	tokens_container.custom_minimum_size = Global.CHARACTER_SIZE
	tokens_container.name = "TokensContainer"
	self.add_child(tokens_container)
	tokens_container.position = Vector2(- Global.CHARACTER_SIZE.x / 2, - Global.CHARACTER_SIZE.y * 2)
#endregion


func _ready() -> void:
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
	anim_idle(start_frame)


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
func do_attack_action(target_battler: Battler, target_group: Array[Battler] = [], is_first_call := true): # TODO: bad code -> both target_battler and target_group :/
	action_value = int(stats.generate_damage_value())
	damage_modifier = 0
	is_stimed = false
	miss_chance = 0
	
	self.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_ATTACKING)
	
	if target_group.is_empty():
		_perform_attack(target_battler, is_first_call)
	else:
		for b in target_group:
			_perform_attack(b, is_first_call)
	
	if type == Types.HERO_ROBBER and is_first_call and target_battler.is_alive:
		await get_tree().create_timer(0.25).timeout
		do_attack_action(target_battler, [], false)
	else:
		self.token_handler.check_tokens()
		if target_group.is_empty():
			target_battler.token_handler.check_tokens()
		else:
			for b in target_group:
				b.token_handler.check_tokens()


func _perform_attack(target_battler: Battler, is_first_call: bool):
	target_battler.defense_modifier = 0
	target_battler.mirror_modifier = 0
	target_battler.dodge_chance = 0
	
	target_battler.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_GET_ATTACKED)
	var is_avoid := randf() < 1.0 - calc_hit_chance(target_battler)
	
	if is_avoid:
		target_battler.anim_value_label(Battler.ActionTypes.ATTACK, str("ПРОМАХ"))
	else:
		self.token_handler.apply_tokens(Token.ApplyMoments.ON_ATTACKING)
		target_battler.token_handler.apply_tokens(Token.ApplyMoments.ON_GET_ATTACKED)
		var result := calc_damage_value(action_value, target_battler)
		target_battler.stats.adjust_health(- result)
	
		if target_battler.mirror_modifier > 0:
			await get_tree().create_timer(0.25).timeout
			self.stats.adjust_health(- ceili(result * target_battler.mirror_modifier / 100.0) )


func calc_damage_value(value: int, target_battler: Battler) -> int:
	return roundi( value * (1 + damage_modifier / 100.0 - target_battler.defense_modifier / 100.0) )


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


func _on_health_changed(value: int, delta: int):
	health_bar.set_bar_value(value)
	var action_type := (
			Battler.ActionTypes.ATTACK if delta < 0
			else Battler.ActionTypes.ALLY if delta > 0
			else Battler.ActionTypes.NONE
	)
	if value > 0:
		if is_about_to_die:
			anim_and_set_about_to_die(false)
		else:
			anim_value_label(action_type, str(delta))


func _on_health_depleted():
	var deaths_door_resist := self.stats.get_deaths_door_resist()
	if deaths_door_resist != null:
		if not is_about_to_die or deaths_door_resist.try_to_resist():
			anim_value_label(ActionTypes.ATTACK, str("СОПРОТИВЛЕНИЕ"))
			anim_and_set_about_to_die(true)
			return
	
	anim_value_label(ActionTypes.ATTACK, str("СМЕРТЬ"))
	anim_and_set_about_to_die(false)
	is_alive = false
	health_bar.hide()
	tokens_container.hide()
	tokens.clear()
	anim_die()
	died.emit()
#endregion


#region Tokens

#endregion


#region Animations
func anim_idle(start_frame: int = 0):
	sprite.play(Animations.IDLE)
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	sprite.set_frame_and_progress(start_frame, float(start_frame) / frames_count)
	check_offset(Animations.IDLE)


func anim_prepare(type: ActionTypes):
	match type:
		ActionTypes.ATTACK:
			sprite.play(Animations.PREPARE_ATTACK)
			check_offset(Animations.PREPARE_ATTACK)
		ActionTypes.ALLY:
			sprite.play(Animations.PREPARE_ALLY)
			check_offset(Animations.PREPARE_ALLY)
		_:
			sprite.play(Animations.IDLE)
			check_offset(Animations.IDLE)


func anim_action(type: ActionTypes):
	match type:
		ActionTypes.ATTACK:
			sprite.play(Animations.ACTION_ATTACK)
			check_offset(Animations.ACTION_ATTACK)
		ActionTypes.ALLY:
			sprite.play(Animations.ACTION_ALLY)
			check_offset(Animations.ACTION_ALLY)
		_:
			sprite.play(Animations.IDLE)
			check_offset(Animations.IDLE)


func anim_reaction(type: ActionTypes):
	var offsets := (sprite.sprite_frames as MySpriteFrames).separate_offsets
	match type:
		ActionTypes.ATTACK:
			if offsets.has(Animations.HURT):
				sprite.offset = offsets.get(Animations.HURT)
			sprite.play(Animations.HURT)
			check_offset(Animations.HURT)
		ActionTypes.ALLY:
			sprite.play(Animations.BUFF)
			check_offset(Animations.BUFF)
		_:
			sprite.play(Animations.IDLE)
			check_offset(Animations.IDLE)


func anim_die():
	sprite.play(Animations.DIE)
	health_bar.hide()
	check_offset(Animations.DIE)


func check_offset(anim: String):
	var offset_dict := (sprite.sprite_frames as MySpriteFrames).separate_offsets
	if offset_dict.has(anim):
		sprite.offset = offset_dict.get(anim)
	else:
		sprite.offset = (sprite.sprite_frames as MySpriteFrames).offset


func anim_value_label(current_action_type: Battler.ActionTypes, text: String):
	var value_label := RichTextLabel.new()
	value_label.theme = Preloader.default_theme
	value_label.bbcode_enabled = true
	value_label.scroll_active = false
	value_label.add_theme_color_override("default_color", Color.WHITE)
	value_label.add_theme_color_override("font_outline_color", Color.BLACK)
	value_label.add_theme_constant_override("outline_size", 8)
	value_label.add_theme_font_size_override("normal_font_size", 24)
	value_label.custom_minimum_size = Vector2(Global.CHARACTER_SIZE.x * 2, 30)
	value_label.name = "ValueLabel"
	value_label.z_index = 100
	self.add_child(value_label)
	
	value_label.text = (
			"[center]"
			+ ("" if not text.is_valid_int() or text.begins_with("-") or text == "0" else "+")
			+ text
			+ "[/center]"
	)
	value_label.update_minimum_size()
	value_label.position = Vector2.UP * Global.CHARACTER_SIZE.y / 2 + Vector2.LEFT * value_label.size.x / 2
	value_label.modulate = (
				Global.TargetColors.FOE_BATTLER if current_action_type == Battler.ActionTypes.ATTACK
				else Global.TargetColors.ALLY_BATTLER
	)
	var tween := create_tween()
	tween.tween_property(
			value_label, "position:y",
			value_label.position.y - Global.CHARACTER_SIZE.y / 2,
			BattleAnimator.ACTION_TIME
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
			value_label, "modulate:a",
			0.0,
			0.1
	)
	tween.tween_interval(0.1)
	tween.tween_callback(value_label.queue_free)


func anim_and_set_about_to_die(value: bool):
	is_about_to_die = value
	if is_about_to_die:
		if not tween_dying:
			tween_dying = create_tween().set_loops()
			tween_dying.tween_property(
					sprite, "self_modulate",
					Color.RED,
					0.5
			)
			tween_dying.tween_property(
					sprite, "self_modulate",
					Color.WHITE,
					0.5
			)
		else:
			tween_dying.play()
	else:
		if tween_dying and tween_dying.is_running():
			tween_dying.pause()
		sprite.self_modulate = Color.WHITE
#endregion


#region Static functions
static func get_sprite_frames(type: Types) -> SpriteFrames:
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
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func get_offset(type: Types) -> Vector2:
	match type:
		Types.HERO_KNIGHT:
			return Preloader.sprite_frames_knight.offset
		Types.HERO_ROBBER:
			return Preloader.sprite_frames_robber.offset
		Types.HERO_MAGE:
			return Preloader.sprite_frames_mage.offset
		Types.ENEMY_GOBLIN:
			return Preloader.sprite_frames_goblin.offset
		Types.ENEMY_FIRE_IMP:
			return Preloader.sprite_frames_fire_imp.offset
		Types.ENEMY_BEAR:
			return Preloader.sprite_frames_bear.offset
		Types.ENEMY_ENT:
			return Preloader.sprite_frames_ent.offset
		_:
			assert(false, "Wrong type: " + str(type))
			return Vector2.ZERO


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
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func get_scale_x(type: Types) -> int:
	if type in HEROES:
		return 1
	elif type in MOBS:
		return -1
	else:
		assert(false, "Wrong type: " + str(type))
		return 0


static func get_type_as_string(type: Types) -> String:
	match type:
		Types.HERO_KNIGHT:
			return "Рыцарь"
		Types.HERO_ROBBER:
			return "Разбойник"
		Types.HERO_MAGE:
			return "Маг"
		Types.ENEMY_GOBLIN:
			return "Гоблин"
		Types.ENEMY_FIRE_IMP:
			return "Чорт"
		Types.ENEMY_BEAR:
			return "Медведь"
		Types.ENEMY_ENT:
			return "Энт"
		_:
			assert(false, "Wrong type: " + str(type))
			return ""

#endregion
