extends Node

@export_group("Game Screens")
@export var battle_scene: PackedScene
@export var game_scene: PackedScene
@export var level_scene: PackedScene
@export var credits_scene: PackedScene
@export var http_test_scene: PackedScene

@export_group("Battler Stats", "stats_")
@export var stats_fire_imp: BattlerStats
@export var stats_goblin: BattlerStats
@export var stats_bear: BattlerStats
@export var stats_ent: BattlerStats
@export var stats_knight: BattlerStats
@export var stats_mage: BattlerStats
@export var stats_robber: BattlerStats

@export_group("Sprite Frames", "sprite_frames_")
@export var sprite_frames_fire_imp: MySpriteFrames
@export var sprite_frames_goblin: MySpriteFrames
@export var sprite_frames_bear: MySpriteFrames
@export var sprite_frames_ent: MySpriteFrames
@export var sprite_frames_knight: MySpriteFrames
@export var sprite_frames_mage: MySpriteFrames
@export var sprite_frames_robber: MySpriteFrames

@export_group("Textures", "texture_") # TODO: move export var textures to nodes ????????????????????
@export var texture_selection: Texture2D
@export var texture_selection_hover: Texture2D
@export var texture_sword_yellow_icon: Texture2D
@export var texture_shield_yellow_icon: Texture2D
@export var texture_person_yellow_icon: Texture2D
@export var texture_arrow_right_yellow_icon: Texture2D
@export var texture_arrow_left_yellow_icon: Texture2D
@export var texture_under_progress_bar: Texture2D
@export var texture_over_progress_bar: Texture2D
@export var texture_red_progress_bar: Texture2D
@export var texture_green_progress_bar: Texture2D
@export var texture_blue_progress_bar: Texture2D
@export var texture_yellow_progress_bar: Texture2D
@export var texture_coin: Texture2D
@export var texture_skull: Texture2D

@export_group("Audio", "audio_")
@export var audio_game_scene4: AudioStreamOggVorbis
@export var audio_game_scene5: AudioStreamOggVorbis
@export var audio_battle1: AudioStreamOggVorbis
@export var audio_battle2: AudioStreamOggVorbis
@export var audio_battle3: AudioStreamOggVorbis
@export var audio_sfx_victory: AudioStreamOggVorbis
@export var audio_sfx_defeat: AudioStreamOggVorbis
var game_scene_musics: Array[AudioStreamOggVorbis]
var battle_musics: Array[AudioStreamOggVorbis]

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

@export_group("Tokens", "token_")
@export var token_attack: Token
@export var token_shield: Token
@export var token_mirror: Token
@export var token_dodge: Token
@export var token_heal_timed: Token
@export var token_stim: Token
@export var token_reachless: Token
@export var token_fire: Token
@export var token_stun: Token
@export var token_antishield: Token
@export var token_antiattack: Token
@export var token_blind: Token
@export var token_taunt: Token
@export var token_more_death_resist: Token
@export var token_less_death_resist: Token

@export_group("UIs")
@export var default_theme: Theme
@export var my_progress_bar: PackedScene
@export var icon_label: PackedScene
@export var level_container: PackedScene
@export var level_page: PackedScene


func _ready() -> void:
	assert(game_scene and http_test_scene and battle_scene and level_scene and credits_scene)
	assert(stats_goblin and stats_knight and stats_mage and stats_robber)
	assert(sprite_frames_knight and sprite_frames_robber and sprite_frames_mage and sprite_frames_goblin)
	assert(texture_selection and texture_selection_hover and texture_sword_yellow_icon
			and texture_shield_yellow_icon and texture_person_yellow_icon and texture_arrow_right_yellow_icon
			and texture_under_progress_bar and texture_over_progress_bar and texture_red_progress_bar
			and texture_green_progress_bar and texture_blue_progress_bar and texture_yellow_progress_bar
			and texture_coin and texture_skull and texture_arrow_left_yellow_icon)
	assert(audio_battle1 and audio_battle2 and audio_battle3
			and audio_game_scene4 and audio_game_scene5)
	assert(rune_comet and rune_dark and rune_fire and rune_ice and rune_spikes and rune_stun and rune_tesla
			and rune_tornado and rune_water)
	assert(token_fire and token_shield and token_antiattack and token_antishield and token_blind 
			and token_dodge and token_heal_timed and token_less_death_resist and token_mirror 
			and token_more_death_resist and token_reachless and token_stim and token_stun and token_taunt)
	assert(default_theme and my_progress_bar and icon_label and level_container and level_page)
	
	game_scene_musics = [ audio_game_scene4, audio_game_scene5 ]
	battle_musics = [ audio_battle1, audio_battle2, audio_battle3 ]
