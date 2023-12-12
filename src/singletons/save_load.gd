class_name SaveLoad
extends Object

const _SETTINGS_FILENAME := "user_settings.cfg"
const _DATA_FILENAME := "player.dat"
const _USER_DATA_PREFIX := "user://"
const _SETTINGS_FILE_PATH: String = _USER_DATA_PREFIX + _SETTINGS_FILENAME
const _DATA_FILE_PATH: String = _USER_DATA_PREFIX + _DATA_FILENAME


#func _ready() -> void:
#	print_debug(OS.get_user_data_dir())

## Returns settings as Disctionary from file at user data path. If error occured or the file is empty, creates new one and proceeds.
static func load_settings() -> Dictionary:
	var settings: Dictionary = {}
	var file := ConfigFile.new()
	var error: Error = file.load(_SETTINGS_FILE_PATH)
	if error != OK or file.get_sections().is_empty():
		_create_default_settings_file(file)
	for settings_section in (file.get_sections() as PackedStringArray):
		settings[settings_section] = {}
		for setting_name in (file.get_section_keys(settings_section) as PackedStringArray):
			settings[settings_section][setting_name] = file.get_value(settings_section, setting_name)
	
	return settings

## WIP. Returns player data as Dictionary from file at user data path. If error occured, ???.
static func load_data() -> Dictionary:
	var data: Dictionary = {}
	var file := FileAccess.open(_DATA_FILE_PATH, FileAccess.READ)
	var error: Error = FileAccess.get_open_error()
	if error != OK or file.get_length() == 0:
		file.close()
		_create_default_data_file(file)
		file = FileAccess.open(_DATA_FILE_PATH, FileAccess.READ)
	
	var json_string := file.get_line()
	var json = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else:
		data = json.data
	
	file.close()
	return data

## Saves settings to file at user data path. 
static func save_settings(settings: Dictionary = Global.settings):
	var file := ConfigFile.new()
	var error: Error = file.load(_SETTINGS_FILE_PATH)
	assert(error == OK)
	_write_settings_to_file(settings, file)
	file.save(_SETTINGS_FILE_PATH)

## WIP.
static func save_data():
	var file := FileAccess.open(_DATA_FILE_PATH, FileAccess.WRITE)
	var error: Error = FileAccess.get_open_error()
	assert(error == OK)
	var json_string = JSON.stringify(Global.player_data)
	file.store_line(json_string)
	file.close()


static func erase_settings():
	var file := ConfigFile.new()
	var error: Error = file.load(_SETTINGS_FILE_PATH)
	if error == OK:
		file.clear()
		file.save(_SETTINGS_FILE_PATH)

## Creates empty settings file of class ConfigFile with Global.DEFAULT_SETTINGS. Prints error if occured.
static func _create_default_settings_file(file: ConfigFile):
	_write_settings_to_file(Global.DEFAULT_SETTINGS, file)
	var error: Error = file.save(_SETTINGS_FILE_PATH)
	if error != OK:
		print_debug(error_string(error))

## Creates empty data file of class FileAccess. Prints error if occured.
static func _create_default_data_file(file: FileAccess):
	file = FileAccess.open(_DATA_FILE_PATH, FileAccess.WRITE)
	var error: Error = FileAccess.get_open_error()
	if error != OK:
		print_debug(error_string(error))
	var json_string = JSON.stringify(Global.DEFAULT_DATA)
	file.store_line(json_string)
	file.close()

## Writes settings to file.
static func _write_settings_to_file(settings: Dictionary, file: ConfigFile):
	for settings_section in settings.keys() as Array[String]:
		for setting_name in settings.get(settings_section).keys() as Array[String]:
			var value = settings.get(settings_section).get(setting_name)
			file.set_value(settings_section, setting_name, value)
