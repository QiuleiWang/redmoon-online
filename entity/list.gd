extends Object
var Entry =preload("res://entity/entry.gd")
var ListItem = preload("res://entity/list_item.gd")
var items={}

func read(buffer,version="1.0"):
	var next_free_id = buffer.get_u32()
	var entry_count = buffer.get_u32()
	for _i in range(entry_count):
		var name = buffer.get_utf8_string(buffer.get_u8())
		var id = buffer.get_u32()
		var file_number = buffer.get_u32()		
		var index = buffer.get_u32()
		if version=="1.2":
			buffer.get_u32()
		var entry=Entry.new()
		entry.file=file_number
		entry.index=index
		var item = ListItem.new()
		item.name = name
		item.id = id
		item.entry=entry
		items[id]=item
func get_item(index):
	return items.get(index)
func serialize():
	var iteams_array=[]
	for item in items:
		iteams_array.append(item.serialize())
	return iteams_array
