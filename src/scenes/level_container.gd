class_name LevelContainer
extends MarginContainer

signal clicked

const DEFAULT := Color(1.0, 1.0, 1.0)
const CIRCLE_UNSELECTED := Color(0.5, 0.5, 0.5)
const STAR_BLACK := Color(0.2, 0.2, 0.2)
const DOOR_LOCKED := Color(0.5, 0.5, 0.5)

@export var circle: TextureRect
@export var door: TextureRect
@export var select: TextureRect
@export var level_number_label: Label
@export var lock: TextureRect
@export var stars: Array[TextureRect]

var level_number: int


static func create(level: int) -> LevelContainer:
	var instance := Preloader.level_container.instantiate() as LevelContainer
	instance._set_level(level)
	instance.name = "Level" + str(level)
	return instance


func _ready() -> void:
	assert(circle and door and select and level_number_label and lock and stars and stars.size() == 3)


func _gui_input( event: InputEvent ) -> void:
	if event is InputEventMouseButton and event.is_pressed() and not is_locked():
		circle.modulate = DEFAULT
		select.show()
		clicked.emit()


func deselect():
	if not is_locked():
		circle.modulate = CIRCLE_UNSELECTED
		select.hide()


func is_locked() -> bool:
	return level_number > Global.get_player_last_enemy_level_reached()


func _set_level(level_number: int):
	self.level_number = level_number
	level_number_label.text = str(level_number)
	circle.modulate = CIRCLE_UNSELECTED
	select.hide()
	if is_locked():
		door.modulate = DOOR_LOCKED
		lock.show()
		for star in stars:
			star.hide()
	else:
		door.modulate = DEFAULT
		lock.hide()
		for i in stars.size():
			if Global.get_player_enemy_level_stars(level_number) <= i:
				stars[i].modulate = STAR_BLACK
			else:
				stars[i].modulate = DEFAULT
