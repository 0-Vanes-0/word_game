## This is global script which stores global variables and helps with some global processes
## like pausing game, switching scenes etc.
extends Node

# ---------------------- CONSTANTS ----------------------

var SCREEN_WIDTH: int; var SCREEN_HEIGHT: int; var RATIO := ":"
const CHARACTER_SIZE := Vector2(60, 120)
const TargetColors := {
	CURRENT_BATTLER = Color.YELLOW,
	FOE_BATTLER = Color.BROWN,
	ALLY_BATTLER = Color.CORNFLOWER_BLUE,
}
const DEFAULT_SETTINGS := {
	MUSIC = true
}
const DEFAULT_DATA := {
	"id": 1,
	"levels": {
		"knight_level": 1,
		"robber_level": 1,
		"mage_level": 1,
	},
	"coins": 0,
	"last_hero_choice": [Battler.Types.HERO_MAGE, Battler.Types.HERO_ROBBER, Battler.Types.HERO_KNIGHT],
}

# ---------------------- VARIABLES ----------------------

var settings: Dictionary
var player_data: Dictionary

# ---------------------- ON START ----------------------

func _ready() -> void:
	setup()


func setup():
	SCREEN_WIDTH = int(get_viewport().get_visible_rect().size.x)
	SCREEN_HEIGHT = int(get_viewport().get_visible_rect().size.y)
	var gcd := _gcd(SCREEN_WIDTH, SCREEN_HEIGHT)
	RATIO = str(SCREEN_WIDTH / gcd) + RATIO + str(SCREEN_HEIGHT / gcd)
	print_debug("\t", "SCREEN_WIDTH=", SCREEN_WIDTH, ", SCREEN_HEIGHT=", SCREEN_HEIGHT, ", RATIO=", RATIO)
	
	randomize()
	
	player_data = SaveLoad.load_data()

# ---------------------- PLAYER DATA SETTERS & GETTERS ----------------------

func set_player_id(value: int):
	player_data["id"] = value
	SaveLoad.save_data()
func get_player_id() -> int:
	return player_data.get("id") as int

func set_player_level(battler_type: Battler.Types, value: int):
	match battler_type:
		Battler.Types.HERO_KNIGHT:
			player_data["levels"]["knight_level"] = value
		Battler.Types.HERO_ROBBER:
			player_data["levels"]["robber_level"] = value
		Battler.Types.HERO_MAGE:
			player_data["levels"]["mage_level"] = value
		_:
			assert(false, str(battler_type))
	SaveLoad.save_data()
func get_player_level(battler_type: Battler.Types) -> int:
	match battler_type:
		Battler.Types.HERO_KNIGHT:
			return player_data.get("levels").get("knight_level") as int
		Battler.Types.HERO_ROBBER:
			return player_data.get("levels").get("robber_level") as int
		Battler.Types.HERO_MAGE:
			return player_data.get("levels").get("mage_level") as int
		_:
			assert(false, str(battler_type))
			return 0

func set_player_coins(value: int):
	player_data["coins"] = value
	SaveLoad.save_data()
func get_player_coins() -> int:
	return player_data.get("coins") as int

func set_player_last_hero_choice(value: Array):
	assert(value.size() == 3, "Wrong array size:" + str(value))
	player_data["last_hero_choice"] = value
	SaveLoad.save_data()
func get_player_last_hero_choice() -> Array:
	return player_data.get("last_hero_choice") as Array

# ---------------------- FUNCTIONS ----------------------

## Tells [SceneHandler] to switch to [PackedScene].
func switch_to_scene(scene: PackedScene):
	var scene_handler = get_tree().current_scene
	if scene_handler is SceneHandler:
		scene_handler.switch_to_scene(scene)
	else:
		print_debug("scene_handler is missing!!!")

## Returns current scene of [SceneHandler].
func get_current_scene() -> Node:
	var scene_handler = get_tree().current_scene
	if scene_handler is SceneHandler:
		return scene_handler.current_scene
	else:
		print_debug("scene_handler is missing!!!")
		return null

# NOD
func _gcd(a: int, b: int) -> int:
	while a > 0 and b > 0:
		if a > b:
			a %= b
		else:
			b %= a
	return a + b
