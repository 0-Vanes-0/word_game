class_name BattleScene
extends Node2D


func _ready() -> void:
	_test_sprites()


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta
#	$Background/ParallaxBackground.scroll_offset += Vector2.RIGHT * 20 * delta


func _test_sprites():
	var vectors: Array[Vector2] = [
		Vector2(100, 480),
		Vector2(200, 480),
		Vector2(300, 480),
		Vector2(600, 480),
		Vector2(700, 480),
		Vector2(800, 480),
	]
	for i in 6:
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = preload("res://game_resources/sprite_frames/knight_sprite_frames.tres")
		$Battlers.add_child(sprite)
		sprite.play("default")
		sprite.position = vectors[i]
