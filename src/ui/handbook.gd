class_name Handbook
extends ColorRect

@export var tabbar: TabBar
@export var tab_container: TabContainer
@export var hide_button: TextureButton


func _ready() -> void:
	assert(tabbar and tab_container and hide_button)
	tabbar.tab_changed.connect(
			func(tab: int):
				tab_container.current_tab = tab
	)
	hide_button.pressed.connect(
			func():
				self.hide()
	)
	tabbar.current_tab = 0
	tab_container.current_tab = 0
