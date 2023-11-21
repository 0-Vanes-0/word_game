extends Node

@export_group("Game Screens")
@export var battle_scene: PackedScene
@export var game_scene: PackedScene
@export var http_test_scene: PackedScene

@export_group("Sprite Frames", "sprite_frames_")
@export var sprite_frames_goblin: MySpriteFrames
@export var sprite_frames_knight: MySpriteFrames
@export var sprite_frames_mage: MySpriteFrames
@export var sprite_frames_robber: MySpriteFrames

@export_group("Battler Stats", "stats_")
@export var stats_goblin: BattlerStats
@export var stats_knight: BattlerStats
@export var stats_mage: BattlerStats
@export var stats_robber: BattlerStats


func _ready() -> void:
	assert(game_scene and http_test_scene and battle_scene)
	assert(sprite_frames_knight and sprite_frames_robber and sprite_frames_mage and sprite_frames_goblin)
	assert(stats_goblin and stats_knight and stats_mage and stats_robber)
