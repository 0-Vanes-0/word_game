extends Node

@export var http_node: HTTPManager
@export var domain: String = "http://192.168.0.25"

@export_group("Player data", "player_")
@export var player_name := ""
@export var player_level: int = 1
@export var player_donater: bool = false


func _ready() -> void:
	assert(http_node)
	
#	http_node.job(
#			"http://192.168.0.25/new"
#	).on_success(
#			func(result: ApplicationOctetStream):
#				print(result.response_code)
#				print(result.response_headers)
#				print(result.response_mime)
#				print(result.fetch())
#	).launch()
#
#	await get_tree().create_timer(5.0).timeout
	
#	http_node.job(
#			"http://192.168.0.25/getProfile"
#	).add_get({
#			"dictionary": 24
#	}).on_success(
#			func(result: ApplicationOctetStream):
#				print(result.response_code)
#				print(result.response_headers)
#				print(result.response_mime)
#				print(result.fetch())
#	).launch()
	
	
#	assert(http_node)
#	var params := { "dictionary": 24 }
#	var error: Error = http_node.request("http://192.168.0.25/getProfile", [], HTTPClient.METHOD_GET, "dictionary=24")
#	print_debug("request: ", Global.parse_error(error))
#	await get_tree().create_timer(5.0).timeout
#
#	var headers: Array = ["Content-Type: application/json;charset=utf-8"]
#	params = { "nick": "lolkek" }
#	error = http_node.request("http://192.168.0.25/saveNick", PackedStringArray(headers), HTTPClient.METHOD_POST, "nick=asdf")
#	print_debug("request: ", Global.parse_error(error))


func get_success_text(result: ApplicationOctetStream) -> String:
	return (
					str(result.response_code)
			+ "\n" + str(result.response_headers)
			+ "\n" + str(result.response_mime)
			+ "\n" + str(result.fetch())
			+ "\n"
	)


#func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
#	var json = JSON.parse_string(body.get_string_from_utf8())
#	print_debug(result, "    ", response_code, "    ", headers, "    ", json)
