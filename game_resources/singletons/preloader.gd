extends Node

@export_group("Game Screens")
@export var game_scene: PackedScene


func _ready() -> void:
	assert(
		game_scene
	)
