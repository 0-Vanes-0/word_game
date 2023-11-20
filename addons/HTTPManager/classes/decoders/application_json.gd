class_name JSONMimeDecoder
extends TextMimeDecoder


func fetch():
	var charset = response_charset
	if forced_charset != "":
		charset = forced_charset
	var text = as_text( charset )
	return JSON.parse_string( text )
