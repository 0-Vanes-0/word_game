class_name Battler
extends Node2D

signal clicked
signal hold_started
signal hold_stopped
signal died

enum Types {
	NONE = 0,
	KNIGHT = 11, ROBBER = 12, MAGE = 13,
	
	GOBLIN = 21, FIRE_IMP = 22,
}
enum ActionTypes {
	NONE, ATTACK, ALLY
}
const HEROES := [Types.KNIGHT, Types.ROBBER, Types.MAGE]
const MOBS := [Types.GOBLIN, Types.FIRE_IMP]
const Animations := {
	IDLE = "idle",
	PREPARE_ATTACK = "prepare_attack",
	PREPARE_SELF = "prepare_self",
	PREPARE_ALLY = "prepare_ally",
	ACTION_ATTACK = "action_attack",
	ACTION_SELF = "action_self",
	ACTION_ALLY = "action_ally",
	HURT = "hurt",
	DIE = "die",
}

var type: Types
var stats: BattlerStats
var index: int = -1
var is_alive: bool = true
var is_clickable: bool = false
var tokens: Array[Token] = []

var sprite: AnimatedSprite2D
var selection_hover: Sprite2D
var selection: Sprite2D
var size_area: Area2D
var coll_shape: CollisionShape2D
var health_bar: MyProgressBar
var tokens_container: VBoxContainer
var value_label: RichTextLabel


static func create(type: Types, stats: BattlerStats, index: int) -> Battler:
	return Battler.new(type, stats, index)


#region Init
func _init(type: Types, stats: BattlerStats, index: int) -> void:
	self.type = type
	self.stats = stats.get_resource()
	self.stats.health_changed.connect(
			func(value: int):
				health_bar.value = value
	)
	self.stats.health_depleted.connect(
			func():
				anim_die() # TODO: MOVE TO BATTLE ANIMATOR
				health_bar.hide()
				is_alive = false
				tokens.clear()
				died.emit()
	)
	self.index = index
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Battler.get_sprite_frames(type)
	sprite.offset = Battler.get_offset(type)
	sprite.scale = Vector2(Battler.get_scale_x(type), 1) * 2.0
	self.add_child(sprite)
	
	selection_hover = Sprite2D.new()
	selection_hover.texture = Preloader.texture_selection_hover
	selection_hover.offset = Vector2.UP * 25
	selection_hover.scale = Vector2.ONE * 2.0
	self.add_child(selection_hover)
	selection_hover.hide()
	
	selection = Sprite2D.new()
	selection.texture = Preloader.texture_selection
	selection.offset = Vector2.UP * 25
	selection.scale = Vector2.ONE * 2.0
	self.add_child(selection)
	selection.hide()
	
	size_area = Area2D.new()
	coll_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Global.CHARACTER_SIZE
	coll_shape.shape = shape
	coll_shape.position = Vector2.UP * Global.CHARACTER_SIZE.y / 2
	size_area.add_child(coll_shape)
	self.add_child(size_area)
	size_area.input_event.connect(_on_pressed)
	
	health_bar = MyProgressBar.create(MyProgressBar.Colors.RED)
	self.add_child(health_bar)
	health_bar.position = Vector2.LEFT * health_bar.custom_minimum_size.x / 2
	health_bar.min_value = 0 - 1
	health_bar.max_value = self.stats.max_health + 1
	health_bar.value = health_bar.max_value
	
	tokens_container = VBoxContainer.new()
	tokens_container.alignment = BoxContainer.ALIGNMENT_END
	tokens_container.custom_minimum_size = Global.CHARACTER_SIZE
	self.add_child(tokens_container)
	tokens_container.position = Vector2(- Global.CHARACTER_SIZE.x / 2, - Global.CHARACTER_SIZE.y * 2)
	
	value_label = RichTextLabel.new()
	value_label.theme = Preloader.default_theme
	value_label.bbcode_enabled = true
	value_label.scroll_active = false
	value_label.add_theme_color_override("default_color", Color.WHITE)
	value_label.add_theme_color_override("font_outline_color", Color.BLACK)
	value_label.add_theme_constant_override("outline_size", 8)
	value_label.add_theme_font_size_override("normal_font_size", 24)
	value_label.custom_minimum_size = Vector2(Global.CHARACTER_SIZE.x * 2, 30)
	self.add_child(value_label)
#endregion


func _ready() -> void:
	anim_idle()


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
			if timer < TAP_MAX_TIME and is_clickable:
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


#region Tokens
func add_token(token_type: Token.Types, amount: int = 1):
	for i in amount:
		var token := Token.create(token_type, self)
		tokens.append(token)
	update_token_labels()


func update_token_labels():
	for t_label: TokenLabel in tokens_container.get_children():
		tokens_container.remove_child(t_label)
		t_label.queue_free()
	
	for token in tokens:
		var current_t_label: TokenLabel
		var found_label: bool = false
		for t_label: TokenLabel in tokens_container.get_children():
			if t_label.token.type == token.type:
				found_label = true
				current_t_label = t_label
				break
		
		if not found_label:
			current_t_label = TokenLabel.create()
			current_t_label.token = token
			current_t_label.amount = 1
			current_t_label.duration = token.ticks_count
			tokens_container.add_child(current_t_label)
		else:
			current_t_label.amount += 1
			current_t_label.duration = max(token.ticks_count, current_t_label.duration)
		
	for t_label: TokenLabel in tokens_container.get_children():
		t_label.update_info()


func check_tokens(for_what_moment: Token.ApplyMoments):
	var damage_value: int = 0
	var heal_value: int = 0
	for t in tokens:
		if Token.get_apply_moment(t.type) == for_what_moment:
			if t.type != Token.Types.FIRE:
				heal_value += t.apply_token_effect()
			else:
				damage_value += t.apply_token_effect()
	
	if heal_value > 0:
		anim_value_label(Battler.ActionTypes.ALLY, str(heal_value)) # TODO: make 2nd label :/
		await get_tree().create_timer(0.1).timeout
	if damage_value > 0:
		anim_value_label(Battler.ActionTypes.ATTACK, str(damage_value))
	update_token_labels()


func get_first_token(type: Token.Types) -> Token:
	for t in tokens:
		if t.type == type:
			return t
	return null


func adjust_all_tokens():
	for t in tokens:
		t.adjust_tick_count(-1)
#endregion


#region Animations
func anim_idle():
	sprite.play(Animations.IDLE)
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
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
		#ActionTypes.ALLY:
			#sprite.play(Animations.BUFF)
			#check_offset(Animations.BUFF)
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
	value_label.text = (
			"[center]"
			+ text
			+ "[/center]"
	)
	value_label.show()
	value_label.position = Vector2.UP * Global.CHARACTER_SIZE.y / 2 + Vector2.LEFT * value_label.size.x / 2
	value_label.modulate = (
				Global.TargetColors.FOE_BATTLER if current_action_type == Battler.ActionTypes.ATTACK
				else Global.TargetColors.ALLY_SELF_BATTLER
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
	tween.tween_callback(value_label.hide)
#endregion


#region Static functions
static func get_sprite_frames(type: Types) -> SpriteFrames:
	match type:
		Types.KNIGHT:
			return Preloader.sprite_frames_knight
		Types.ROBBER:
			return Preloader.sprite_frames_robber
		Types.MAGE:
			return Preloader.sprite_frames_mage
		Types.GOBLIN:
			return Preloader.sprite_frames_goblin
		Types.FIRE_IMP:
			return Preloader.sprite_frames_fire_imp
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func get_offset(type: Types) -> Vector2:
	match type:
		Types.KNIGHT:
			return Preloader.sprite_frames_knight.offset
		Types.ROBBER:
			return Preloader.sprite_frames_robber.offset
		Types.MAGE:
			return Preloader.sprite_frames_mage.offset
		Types.GOBLIN:
			return Preloader.sprite_frames_goblin.offset
		Types.FIRE_IMP:
			return Preloader.sprite_frames_fire_imp.offset
		_:
			assert(false, "Wrong type: " + str(type))
			return Vector2.ZERO


static func get_start_stats(type: Types) -> BattlerStats:
	match type:
		Types.KNIGHT:
			return Preloader.stats_knight
		Types.ROBBER:
			return Preloader.stats_robber
		Types.MAGE:
			return Preloader.stats_mage
		Types.GOBLIN:
			return Preloader.stats_goblin
		Types.FIRE_IMP:
			return Preloader.stats_fire_imp
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
		Types.KNIGHT:
			return "Рыцарь"
		Types.ROBBER:
			return "Разбойник"
		Types.MAGE:
			return "Маг"
		Types.GOBLIN:
			return "Гоблин"
		Types.FIRE_IMP:
			return "Чорт"
		_:
			assert(false, "Wrong type: " + str(type))
			return ""
#endregion
