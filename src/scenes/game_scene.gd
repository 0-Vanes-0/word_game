class_name GameScene
extends Node2D


func _ready() -> void:
	pass


func _on_enter_fight_button_pressed() -> void:
	Global.switch_to_scene(Preloader.battle_scene)
