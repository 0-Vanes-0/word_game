## This is global script which stores global variables and helps with some global processes
## like pausing game, switching scenes etc.
extends Node

# ---------------------- CONSTANTS ----------------------

var SCREEN_WIDTH: int; var SCREEN_HEIGHT: int; var RATIO := ":"
const CHARACTER_SIZE := Vector2(60, 120)
const TargetColors := {
	CURRENT_BATTLER = Color.YELLOW,
	FOE_BATTLER = Color.BROWN,
	ALLY_SELF_BATTLER = Color.CORNFLOWER_BLUE,
}

# ---------------------- VARIABLES ----------------------



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

## Returns [param error] as [String].
func parse_error(error: Error) -> String:
	match error:
		OK: return "OK"
		FAILED: return "FAILED"
		ERR_UNAVAILABLE: return "ERR_UNAVAILABLE"
		ERR_UNCONFIGURED: return "ERR_UNCONFIGURED"
		ERR_UNAUTHORIZED: return "ERR_UNAUTHORIZED"
		ERR_PARAMETER_RANGE_ERROR: return "ERR_PARAMETER_RANGE_ERROR"
		ERR_OUT_OF_MEMORY: return "ERR_OUT_OF_MEMORY"
		ERR_FILE_NOT_FOUND: return "ERR_FILE_NOT_FOUND"
		ERR_FILE_BAD_DRIVE: return "ERR_FILE_BAD_DRIVE"
		ERR_FILE_BAD_PATH: return "ERR_FILE_BAD_PATH"
		ERR_FILE_NO_PERMISSION: return "ERR_FILE_NO_PERMISSION"
		ERR_FILE_ALREADY_IN_USE: return "ERR_FILE_ALREADY_IN_USE"
		ERR_FILE_CANT_OPEN: return "ERR_FILE_CANT_OPEN"
		ERR_FILE_CANT_WRITE: return "ERR_FILE_CANT_WRITE"
		ERR_FILE_CANT_READ: return "ERR_FILE_CANT_READ"
		ERR_FILE_UNRECOGNIZED: return "ERR_FILE_UNRECOGNIZED"
		ERR_FILE_CORRUPT: return "ERR_FILE_CORRUPT"
		ERR_FILE_MISSING_DEPENDENCIES: return "ERR_FILE_MISSING_DEPENDENCIES"
		ERR_FILE_EOF: return "ERR_FILE_EOF"
		ERR_CANT_OPEN: return "ERR_CANT_OPEN"
		ERR_CANT_CREATE: return "ERR_CANT_CREATE"
		ERR_QUERY_FAILED: return "ERR_QUERY_FAILED"
		ERR_ALREADY_IN_USE: return "ERR_ALREADY_IN_USE"
		ERR_LOCKED: return "ERR_LOCKED"
		ERR_TIMEOUT: return "ERR_TIMEOUT"
		ERR_CANT_CONNECT: return "ERR_CANT_CONNECT"
		ERR_CANT_RESOLVE: return "ERR_CANT_RESOLVE"
		ERR_CONNECTION_ERROR: return "ERR_CONNECTION_ERROR"
		ERR_CANT_ACQUIRE_RESOURCE: return "ERR_CANT_ACQUIRE_RESOURCE"
		ERR_CANT_FORK: return "ERR_CANT_FORK"
		ERR_INVALID_DATA: return "ERR_INVALID_DATA"
		ERR_INVALID_PARAMETER: return "ERR_INVALID_PARAMETER"
		ERR_ALREADY_EXISTS: return "ERR_ALREADY_EXISTS"
		ERR_DOES_NOT_EXIST: return "ERR_DOES_NOT_EXIST"
		ERR_DATABASE_CANT_READ: return "ERR_DATABASE_CANT_READ"
		ERR_DATABASE_CANT_WRITE: return "ERR_DATABASE_CANT_WRITE"
		ERR_COMPILATION_FAILED: return "ERR_COMPILATION_FAILED"
		ERR_METHOD_NOT_FOUND: return "ERR_METHOD_NOT_FOUND"
		ERR_LINK_FAILED: return "ERR_LINK_FAILED"
		ERR_SCRIPT_FAILED: return "ERR_SCRIPT_FAILED"
		ERR_CYCLIC_LINK: return "ERR_CYCLIC_LINK"
		ERR_INVALID_DECLARATION: return "ERR_INVALID_DECLARATION"
		ERR_DUPLICATE_SYMBOL: return "ERR_DUPLICATE_SYMBOL"
		ERR_PARSE_ERROR: return "ERR_PARSE_ERROR"
		ERR_BUSY: return "ERR_BUSY"
		ERR_SKIP: return "ERR_SKIP"
		ERR_HELP: return "ERR_HELP"
		ERR_BUG: return "ERR_BUG"
		ERR_PRINTER_ON_FIRE: return "ERR_PRINTER_ON_FIRE"
		_: return "Unknown error"

# NOD
func _gcd(a: int, b: int) -> int:
	while a > 0 and b > 0:
		if a > b:
			a %= b
		else:
			b %= a
	return a + b
