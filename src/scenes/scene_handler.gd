## This is main scene. It handles [member current_scene], only one can exist.
class_name SceneHandler
extends Node

signal scene_changed(current_scene: Node)

@onready var fade := $CanvasLayer/Fade as ColorRect
var current_scene: Node ## Current scene on screen. Can be changed by [method switch_to_scene].


func _ready() -> void:
	fade.color.a = 0.0
	current_scene = Preloader.game_scene.instantiate()
	self.add_child(current_scene)
	self.move_child(current_scene, 0)
	current_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	scene_changed.emit(current_scene)
	
	#var fps_label := FPSLabel.new()
	#$Control.add_child(fps_label)

## Firstly removes current scene from tree and queues it for freeing, then instantiates a new [param scene].
func switch_to_scene(scene: PackedScene):
	fade.color.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(
			fade, "color:a",
			1.0,
			0.5
	)
	tween.tween_callback(
			func():
				get_tree().node_removed.connect(
						func(node: Node):
							node.queue_free()
				, CONNECT_ONE_SHOT)
				self.remove_child(current_scene)
				current_scene = scene.instantiate()
				self.add_child(current_scene)
				self.move_child(current_scene, 0)
				current_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
				scene_changed.emit(current_scene)
	)
	tween.tween_property(
			fade, "color:a",
			0.0,
			0.5
	)
