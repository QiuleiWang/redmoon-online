extends Node
var character = preload("res://cp949/character_table.gd")

var REPLACEMENT_CHARACTER = 0xFFFD
func lookup_949_char(c: int) -> int:
	for entry in character.CP949_TABLE:
		if entry.cv == c:
			return entry.uv
	return REPLACEMENT_CHARACTER
	
func decode_cp949(data: PoolByteArray) -> String:
	var result = ""
	var cursor = 0
	var input_len = data.size()
	while cursor < input_len:
		var idx = cursor
		var char_code = data[cursor]
		var uni_code_point = 0
		if 0x00 <= char_code and char_code <= 0x7F:
			uni_code_point = char_code
		elif char_code == 0x80 or char_code == 0xFF:
			uni_code_point = REPLACEMENT_CHARACTER
		elif 0x81 <= char_code and char_code <= 0xFE:
			if idx + 1 < input_len:
				var next = data[cursor + 1] as int
				var c = (char_code << 8) + next
				uni_code_point = lookup_949_char(c)
			else:
				uni_code_point = REPLACEMENT_CHARACTER
		else:
			uni_code_point = REPLACEMENT_CHARACTER

		result += char(uni_code_point)
		cursor += 1

	return result
			
