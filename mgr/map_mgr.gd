extends Node
var data_dir = "res://data/datas/Map"
var maps = {}
func load_map(number):
	var path = data_dir.plus_file("Map%05d.rmm" % [number])
	var map = Parsing.parse_file(path)
	self.maps[number]=map

func get_map(number):
	return self.maps.get(number)
