class_name BattleManager
extends Node

@export var battle_scene: BattleScene
var turn_bar: TurnBar

var is_player_turn: bool = true
var current_battler: Battler
var target_battler: Battler


func _ready() -> void:
	assert(battle_scene)
	turn_bar = battle_scene.turn_bar



