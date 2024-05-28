extends Node
var Enums = preload("res://parser/enums.gd")
#
#func get_data(rmdType,number):
#
#
#func load_rmd(rmdType,number):
#	var path=data_config[rmdType] % [number]
#	var rmd = Parsing.parse_file(data_dir.plus_file(path))
#	match rmdType:
#		Enums.RmdType.Tile:
#			tle_map[number] = rmd
#		Enums.RmdType.Obj:
#			obj_map[number] = rmd
#		Enums.RmdType.Icon:
#			ico_map[number] = rmd
#		Enums.RmdType.Character:
#			chr_map[number] = rmd
#		Enums.RmdType.Bullet:
#			bul_map[number] = rmd
#	return rmd
