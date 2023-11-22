extends Node

@export_group("Game Screens")
@export var battle_scene: PackedScene
@export var game_scene: PackedScene
@export var http_test_scene: PackedScene

@export_group("Battler Stats", "stats_")
@export var stats_goblin: BattlerStats
@export var stats_knight: BattlerStats
@export var stats_mage: BattlerStats
@export var stats_robber: BattlerStats

@export_group("Sprite Frames", "sprite_frames_")
@export var sprite_frames_goblin: MySpriteFrames
@export var sprite_frames_knight: MySpriteFrames
@export var sprite_frames_mage: MySpriteFrames
@export var sprite_frames_robber: MySpriteFrames

@export_group("Textures", "texture_")
@export var texture_selection: Texture2D
@export var texture_selection_hover: Texture2D
@export var texture_sword_yellow_icon: Texture2D
@export var texture_sword_black_icon: Texture2D
@export var texture_shield_yellow_icon: Texture2D
@export var texture_shield_black_icon: Texture2D
@export var texture_person_yellow_icon: Texture2D
@export var texture_person_black_icon: Texture2D
@export var texture_arrow_right_yellow_icon: Texture2D
@export var texture_arrow_right_black_icon: Texture2D


func _ready() -> void:
	assert(game_scene and http_test_scene and battle_scene)
	assert(stats_goblin and stats_knight and stats_mage and stats_robber)
	assert(sprite_frames_knight and sprite_frames_robber and sprite_frames_mage and sprite_frames_goblin)
	assert(texture_selection and texture_selection_hover and texture_sword_yellow_icon and texture_sword_black_icon 
			and texture_shield_black_icon and texture_shield_yellow_icon and texture_person_yellow_icon 
			and texture_person_black_icon and texture_arrow_right_yellow_icon and texture_arrow_right_black_icon
			)
