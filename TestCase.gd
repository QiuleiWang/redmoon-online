tool
extends EditorScript
var MapMgr = preload("res://mgr/map_mgr.gd")
func _run():
	testMap()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func testMap():
	var mapMgr = MapMgr.new()
	mapMgr.load_map(3)
