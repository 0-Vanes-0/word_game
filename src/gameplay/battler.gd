class_name Battler
extends Node2D

enum Types {
	NONE = 0,
	KNIGHT = 11, ROBBER = 12, MAGE = 13,
	GOBLIN = 21
}
const HEROES := [Types.KNIGHT, Types.ROBBER, Types.MAGE]
const MOBS := [Types.GOBLIN]
const Animations := {
	IDLE = "idle",
	ATTACK = "attack",
}

var stats: BattlerStats
var animation: SpriteFrames

var sprite: AnimatedSprite2D


static func create(type: Types, stats: BattlerStats) -> Battler:
	return Battler.new(type, stats)


func _init(type: Types, stats: BattlerStats) -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = get_sprite_frames(type)
	sprite.offset = get_offset(type)
	sprite.flip_h = get_flip_h(type)
	sprite.scale = Vector2.ONE * 2.0
	self.add_child(sprite)
	
	self.stats = stats


func _ready() -> void:
	sprite.play(Animations.IDLE)
	var frames_count: int = sprite.sprite_frames.get_frame_count(Animations.IDLE)
	var start_frame: int = randi_range(0, frames_count - 1)
	sprite.set_frame_and_progress(start_frame, float(start_frame) / frames_count)


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
			return Vector2.UP * Preloader.sprite_frames_knight.y_offset
		Types.ROBBER:
			return Vector2.UP * Preloader.sprite_frames_robber.y_offset
		Types.MAGE:
			return Vector2.UP * Preloader.sprite_frames_mage.y_offset
		Types.GOBLIN:
			return Vector2.UP * Preloader.sprite_frames_goblin.y_offset
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


static func get_flip_h(type: Types) -> bool:
	match type:
		Types.KNIGHT, Types.ROBBER, Types.MAGE:
			return false
		Types.GOBLIN:
			return true
		_:
			assert(false, "Wrong type: " + str(type))
			return false
