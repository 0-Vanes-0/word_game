extends Node

@export_group("Game Screens")
@export var battle_scene: PackedScene
@export var game_scene: PackedScene
@export var http_test_scene: PackedScene

@export_group("Battler Stats", "stats_")
@export var stats_fire_imp: BattlerStats
@export var stats_goblin: BattlerStats
@export var stats_knight: BattlerStats
@export var stats_mage: BattlerStats
@export var stats_robber: BattlerStats

@export_group("Sprite Frames", "sprite_frames_")
@export var sprite_frames_fire_imp: MySpriteFrames
@export var sprite_frames_goblin: MySpriteFrames
@export var sprite_frames_knight: MySpriteFrames
@export var sprite_frames_mage: MySpriteFrames
@export var sprite_frames_robber: MySpriteFrames

@export_group("Textures", "texture_") # TODO: move export var textures to nodes ????????????????????
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
@export var texture_under_progress_bar: Texture2D
@export var texture_over_progress_bar: Texture2D
@export var texture_red_progress_bar: Texture2D
@export var texture_green_progress_bar: Texture2D
@export var texture_blue_progress_bar: Texture2D
@export var texture_yellow_progress_bar: Texture2D

@export_group("Runes", "rune_")
@export var rune_comet: Rune
@export var rune_dark: Rune
@export var rune_fire: Rune
@export var rune_ice: Rune
@export var rune_spikes: Rune
@export var rune_stun: Rune
@export var rune_tesla: Rune
@export var rune_tornado: Rune
@export var rune_water: Rune
var test_runes: Array[Rune]

@export_group("Tokens", "token_")
@export var token_attack: Token
@export var token_fire: Token
@export var token_shield: Token

@export_group("UIs")
@export var default_theme: Theme
@export var my_progress_bar: PackedScene
@export var icon_label: PackedScene


func _ready() -> void:
	assert(game_scene and http_test_scene and battle_scene)
	assert(stats_goblin and stats_knight and stats_mage and stats_robber)
	assert(sprite_frames_knight and sprite_frames_robber and sprite_frames_mage and sprite_frames_goblin)
	assert(texture_selection and texture_selection_hover and texture_sword_yellow_icon and texture_sword_black_icon
			and texture_shield_black_icon and texture_shield_yellow_icon and texture_person_yellow_icon
			and texture_person_black_icon and texture_arrow_right_yellow_icon and texture_arrow_right_black_icon
			and texture_under_progress_bar and texture_over_progress_bar and texture_red_progress_bar
			and texture_green_progress_bar and texture_blue_progress_bar and texture_yellow_progress_bar
			)
	assert(rune_comet and rune_dark and rune_fire and rune_ice and rune_spikes and rune_stun and rune_tesla
			and rune_tornado and rune_water)
	assert(token_fire and token_shield)
	assert(default_theme and my_progress_bar and icon_label)

	test_runes = [ rune_comet , rune_dark , rune_fire , rune_ice , rune_spikes , rune_stun , rune_tornado , rune_water, rune_tesla ]
