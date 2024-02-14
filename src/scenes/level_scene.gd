class_name LevelScene
extends Node2D

const PAGE_MAX_ELEMENTS_COUNT := 8.0

@export var back_button: Button
@export var pager: TabContainer
@export var level_info: LevelInfo
var levels: Array[LevelContainer]


func _ready() -> void:
	assert(back_button and pager and level_info)
	level_info.hide()
	
	back_button.pressed.connect(
			func():
				Global.switch_to_scene(Preloader.game_scene)
	)
	
	var page_count := ceili(GameInfo.enemy_levels.size() / PAGE_MAX_ELEMENTS_COUNT)
	for i in page_count:
		var page := LevelPage.create(i, page_count)
		page.previous.connect( func(): pager.current_tab -= 1 )
		page.next.connect( func(): pager.current_tab += 1 )
		pager.add_child(page)
		
		var start: int = i * PAGE_MAX_ELEMENTS_COUNT + 1
		var end: int = (i+1) * PAGE_MAX_ELEMENTS_COUNT
		for j in range(start, end + 1):
			var level := LevelContainer.create(j)
			levels.append(level)
			level.clicked.connect(
					func():
						for l in levels:
							if l.level_number != j:
								l.deselect()
						level_info.appear(j)
			)
			page.add_level(level)
			if j > GameInfo.enemy_levels.size():
				level.modulate.a = 0.0
	
	pager.current_tab = floori(Global.get_player_last_enemy_level_reached() / PAGE_MAX_ELEMENTS_COUNT)


func _get_grid(index: int) -> GridContainer:
	return ((pager.get_child(index) as HBoxContainer).get_child(1) as CenterContainer).get_child(0)


func _get_previous_button(index: int) -> Button:
	return (pager.get_child(index) as HBoxContainer).get_child(0) as Button


func _get_next_button(index: int) -> Button:
	return (pager.get_child(index) as HBoxContainer).get_child(2) as Button
