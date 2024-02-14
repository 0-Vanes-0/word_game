class_name LevelPage
extends HBoxContainer

signal previous
signal next

@export var previous_button: Button
@export var grid: GridContainer
@export var next_button: Button

var page_number: int


static func create(page_number: int, page_max: int) -> LevelPage:
	var instance := Preloader.level_page.instantiate() as LevelPage
	instance.page_number = page_number
	if page_number == 0:
		instance.previous_button.disabled = true
		instance.previous_button.modulate.a = 0.0
	else:
		instance.previous_button.pressed.connect( func(): instance.previous.emit() )
	
	if page_number == page_max-1:
		instance.next_button.disabled = true
		instance.next_button.modulate.a = 0.0
	else:
		instance.next_button.pressed.connect( func(): instance.next.emit() )
	
	return instance


func _ready() -> void:
	assert(previous_button and next_button and grid)


func add_level(level: LevelContainer):
	grid.add_child(level)
