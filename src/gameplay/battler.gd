class_name Battler
extends Node2D

signal clicked

enum Types {
	NONE = 0,
	KNIGHT = 11, ROBBER = 12, MAGE = 13,
	GOBLIN = 21
}
const HEROES := [Types.KNIGHT, Types.ROBBER, Types.MAGE]
const MOBS := [Types.GOBLIN]
const Animations := {
	IDLE = "idle",
	ATTACK = "attack_melee",
}

var stats: BattlerStats

var sprite: AnimatedSprite2D
var selection_hover: Sprite2D
var selection: Sprite2D
var size_area: Area2D
var coll_shape: CollisionShape2D


static func create(type: Types, stats: BattlerStats) -> Battler:
	return Battler.new(type, stats)


func _init(type: Types, stats: BattlerStats) -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = get_sprite_frames(type)
	sprite.offset = get_offset(type)
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
	
	self.stats = stats
	self.scale.x = get_scale_x(type)


func _ready() -> void:
	sprite.play(Animations.IDLE)
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
	sprite.set_frame_and_progress(start_frame, float(start_frame) / frames_count)


func _on_pressed(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()


func set_area_clickable(is_clickble: bool):
	coll_shape.disabled = not is_clickble


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
