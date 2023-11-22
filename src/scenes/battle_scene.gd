class_name BattleScene
extends Node2D

@export_group("Children")
@export var battlers_node: Marker2D

var battlers_positions: Array[Vector2]


func _ready() -> void:
	assert(battlers_node)
	
	battlers_positions.resize(GameInfo.MAX_BATTLERS_COUNT)
	battlers_positions[0] = Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 16
	battlers_positions[1] = Vector2.RIGHT * Global.SCREEN_WIDTH * 4 / 16
	battlers_positions[2] = Vector2.RIGHT * Global.SCREEN_WIDTH * 6 / 16
	battlers_positions[3] = Vector2.RIGHT * Global.SCREEN_WIDTH * 10 / 16
	battlers_positions[4] = Vector2.RIGHT * Global.SCREEN_WIDTH * 12 / 16
	battlers_positions[5] = Vector2.RIGHT * Global.SCREEN_WIDTH * 14 / 16
	
	for i in GameInfo.MAX_BATTLERS_COUNT:
		var battler_type: Battler.Types = GameInfo.battlers_types[i]
		var battler := Battler.create(battler_type, Battler.get_start_stats(battler_type))
		battler.position = battlers_positions[i]
		battlers_node.add_child(battler)


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func _on_back_button_pressed() -> void:
	Global.switch_to_scene(Preloader.game_scene)
