extends Node
var Enums = preload("res://parser/enums.gd")
var LIST_PATHS =[
	[Enums.ListType.Chr0,"Chr/c00.lst"],
	[Enums.ListType.Chr1,"Chr/c01.lst"],
	[Enums.ListType.Chr2,"Chr/c02.lst"],
	[Enums.ListType.Chr3,"Chr/c03.lst"],
	[Enums.ListType.Chr4,"Chr/c04.lst"],
	[Enums.ListType.Chr5,"Chr/c05.lst"],
	[Enums.ListType.Chr6,"Chr/c06.lst"],
	[Enums.ListType.Chr7,"Chr/c07.lst"],
	[Enums.ListType.Chr8,"Chr/c08.lst"],
	[Enums.ListType.Chr9,"Chr/c09.lst"],
	[Enums.ListType.Etc,"Chr/etc.lst"],
	[Enums.ListType.Bullet,"bul.lst"],
	[Enums.ListType.Icon,"ico.lst"],
	[Enums.ListType.Interface,"int.lst"],
	[Enums.ListType.Tile,"tle.lst"],
	[Enums.ListType.Obj,"obj.lst"]
]
var dir_path = "res://data/rles"
var list_map = {}
func _ready():
	for entry in LIST_PATHS:
		var kind = entry[0]
		var path = entry[1]
		list_map[kind]=Parsing.parse_file(dir_path.plus_file(path))

func get_list(type):
	return list_map[type]

