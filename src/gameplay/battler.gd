class_name Battler
extends Node2D

signal clicked
signal hold_started
signal hold_stopped
signal died

enum Types {
	NONE = 0,
	KNIGHT = 11, ROBBER = 12, MAGE = 13,
	
	GOBLIN = 21
}
enum ActionTypes {
	NONE, ATTACK, ALLY
}
const HEROES := [Types.KNIGHT, Types.ROBBER, Types.MAGE]
const MOBS := [Types.GOBLIN]
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


static func create(type: Types, stats: BattlerStats, index: int) -> Battler:
	return Battler.new(type, stats, index)


func _init(type: Types, stats: BattlerStats, index: int) -> void:
	self.type = type
	self.stats = stats.get_resource()
	self.stats.health_changed.connect(
			func(value: int):
				health_bar.value = value
	)
	self.stats.health_depleted.connect(
			func():
				health_bar.hide()
				is_alive = false			
				died.emit()
	)
	self.index = index
	self.scale.x = Battler.get_scale_x(type)
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Battler.get_sprite_frames(type)
	sprite.offset = Battler.get_offset(type)
	sprite.scale = Vector2.ONE * 2.0
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
	health_bar.position = Vector2.LEFT * health_bar.custom_minimum_size.x / 2 * Battler.get_scale_x(type)
	health_bar.min_value = 0 - 1
	health_bar.max_value = self.stats.max_health + 1
	health_bar.value = health_bar.max_value
	health_bar.scale.x = Battler.get_scale_x(type)


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


func add_token(token: Token):
	pass


func check_tokens(for_what_moment: Token.ApplyMoments):
	for t in tokens:
		if Token.get_apply_moment(t.type) == for_what_moment:
			t.apply_token_effect()


#region Animations
func anim_idle():
	sprite.play(Animations.IDLE)
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
	sprite.set_frame_and_progress(start_frame, float(start_frame) / frames_count)
	health_bar.show()


func anim_prepare(type: ActionTypes):
	match type:
		ActionTypes.ATTACK:
			sprite.play(Animations.PREPARE_ATTACK)
		ActionTypes.ALLY:
			sprite.play(Animations.PREPARE_ALLY)
		_:
			sprite.play(Animations.IDLE)


func anim_action(type: ActionTypes):
	match type:
		ActionTypes.ATTACK:
			sprite.play(Animations.ACTION_ATTACK)
		ActionTypes.ALLY:
			sprite.play(Animations.ACTION_ALLY)
		_:
			sprite.play(Animations.IDLE)


func anim_reaction(type: ActionTypes):
	var offsets := (sprite.sprite_frames as MySpriteFrames).separate_offsets
	match type:
		ActionTypes.ATTACK:
			if offsets.has(Animations.HURT):
				sprite.offset = offsets.get(Animations.HURT)
			sprite.play(Animations.HURT)
#		ActionTypes.ALLY:
#			sprite.play(Animations.BUFF)
		_:
			sprite.play(Animations.IDLE)


func anim_die():
	sprite.play(Animations.DIE)
	health_bar.hide()
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
		_:
			assert(false, "Wrong type: " + str(type))
			return null


static func get_scale_x(type: Types) -> int:
	match type:
		Types.KNIGHT, Types.ROBBER, Types.MAGE:
			return 1
		Types.GOBLIN:
			return -1
		_:
			assert(false, "Wrong type: " + str(type))
			return 0
#endregion
