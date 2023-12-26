class_name HTTPTestScene
extends Node2D

@export var label: RichTextLabel
@export var httpr: HTTPRequest
var is_using_plugin := false


#func _ready() -> void:
	#assert(label and httpr)
	#label.clear()
#
#
#func _on_enter_fight_button_pressed() -> void:
	#Global.switch_to_scene(Preloader.battle_scene)
#

#func _on_new_user_button_pressed() -> void:
	#var page := "/new"
	#
	#if is_using_plugin:
		#var http := GameInfo.http_node as HTTPManager
		#http.job(GameInfo.domain + page).on_success(
				#func(result: ApplicationOctetStream):
					#label.add_text(GameInfo.get_success_text(result))
					#label.add_text("------------------------------------------------------------\n")
		#).launch()
		#
	#else:
		#httpr.request_completed.connect(
				#func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
					#label.add_text(
									#str(result)
							#+ "\n" + str(response_code)
							#+ "\n" + str(headers)
							#+ "\n" + str(JSON.parse_string(body.get_string_from_utf8()))
							#+ "\n"
					#)
					#label.add_text("------------------------------------------------------------\n")
		#, CONNECT_ONE_SHOT)
		#httpr.request(GameInfo.domain + page)
#
#
#func _on_get_profile_button_pressed() -> void:
	#var page := "/getProfile"
	#var params := { "dictionary": 24 }
	#
	#if is_using_plugin:
		#var http := GameInfo.http_node as HTTPManager
		#http.job(GameInfo.domain + page).add_get(
				#params
		#).on_success(
				#func(result: ApplicationOctetStream):
					#label.add_text(GameInfo.get_success_text(result))
					#label.add_text("------------------------------------------------------------\n")
		#).launch()
		#
	#else:
		#httpr.request_completed.connect(
				#func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
					#label.add_text(
									#str(result)
							#+ "\n" + str(response_code)
							#+ "\n" + str(headers)
							#+ "\n" + str(JSON.parse_string(body.get_string_from_utf8()))
							#+ "\n"
					#)
					#label.add_text("------------------------------------------------------------\n")
		#, CONNECT_ONE_SHOT)
		#httpr.request(GameInfo.domain + page, [], HTTPClient.METHOD_GET, params.keys()[0] + "=" + str(params.get(params.keys()[0])))
#
#
#func _on_save_nick_button_pressed() -> void:
	#var page := "/saveNick"
	#var params := { "nick": "name" + str(randi()) }
	#label.add_text("Generated nick: " + params.get("nick") + "\n")
	#
	#if is_using_plugin:
		#var http := GameInfo.http_node as HTTPManager
		#http.job(GameInfo.domain + page).add_post(
				#params
		#).on_success(
				#func(result: ApplicationOctetStream):
					#label.add_text(GameInfo.get_success_text(result))
					#label.add_text("------------------------------------------------------------\n")
		#).launch()
		#
	#else:
		#httpr.request_completed.connect(
				#func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
					#label.add_text(
									#str(result)
							#+ "\n" + str(response_code)
							#+ "\n" + str(headers)
							#+ "\n" + str(JSON.parse_string(body.get_string_from_utf8()))
							#+ "\n"
					#)
					#label.add_text("------------------------------------------------------------\n")
		#, CONNECT_ONE_SHOT)
		#httpr.request(GameInfo.domain + page, ["Content-Type: application/json;charset=utf-8"], HTTPClient.METHOD_POST, params.keys()[0] + "=" + str(params.get(params.keys()[0])))
#
#
#func _on_check_box_toggled(button_pressed: bool) -> void:
	#is_using_plugin = button_pressed
