extends Node
var Enums = preload("res://parser/enums.gd")
var data_dir = "res://data/datas"
var tle_map = {}
var obj_map = {}
var ico_map = {}
var chr_map = {}
var bul_map = {}

var data_config = {
	Enums.RmdType.Tile:"Tle/tle%05d.rmd",
	Enums.RmdType.Obj:"Obj/obj%05d.rmd",
	Enums.RmdType.Icon:"Tle/ico%05d.rmd",
	Enums.RmdType.Character:"Chr/chr%05d.rmd",
	Enums.RmdType.Bullet:"Bul/bul%05d.rmd"
	}
func get_data(rmdType,number):
	var rmd = req_data(rmdType,number)
	if rmd==null:
		rmd = load_rmd(rmdType,number)
	return rmd

func getCharacter(id):
	return get_data(Enums.RmdType.Character,id)
	
func req_data(rmdType,number):
	match rmdType:
		Enums.RmdType.Tile:
			return tle_map.get(number)
		Enums.RmdType.Obj:
			return obj_map.get(number)
		Enums.RmdType.Icon:
			return ico_map.get(number)
		Enums.RmdType.Character:
			return chr_map.get(number)
		Enums.RmdType.Bullet:
			return bul_map.get(number)
func load_rmd(rmdType,number):
	var path=data_config[rmdType] % [number]
	#print("rmd path:",path)
	var rmd = Parsing.parse_file(data_dir.plus_file(path),number)
	match rmdType:
		Enums.RmdType.Tile:
			tle_map[number] = rmd
		Enums.RmdType.Obj:
			obj_map[number] = rmd
		Enums.RmdType.Icon:
			ico_map[number] = rmd
		Enums.RmdType.Character:
			chr_map[number] = rmd
		Enums.RmdType.Bullet:
			bul_map[number] = rmd
	return rmd
