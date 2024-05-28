extends Node2D
var Enums =preload("res://parser/enums.gd")
var Entry =preload("res://entity/entry.gd")
var RmdAnimation =preload("res://entity/rmd_animation.gd")
var RmdEntry =preload("res://entity/rmd_entry.gd")
var RmdImage =preload("res://entity/rmd_image.gd")
var Rmd =preload("res://entity/rmd.gd")
var ResFile =preload("res://entity/resource_file.gd")
var Res=preload("res://entity/resource.gd")
var Rmi=preload("res://entity/rmi.gd")
var Map=preload("res://entity/map.gd")
var MapTile=preload("res://entity/map_tile.gd")
var Event=preload("res://entity/event.gd")
var List=preload("res://entity/list.gd")
var RSprite = preload("res://entity/sprite.gd")
var SpriteEntry = preload("res://entity/sprite_entry.gd")
func getBuffer(path):
	var file = File.new()
	file.open(path, File.READ)
	var buffer = StreamPeerBuffer.new()
	buffer.data_array=file.get_buffer(file.get_len())
	buffer.big_endian =false
	file.close()
	return buffer
	
func parse_string(buffer):
	return buffer.get_utf8_string(buffer.get_u8())

func cp949_to_utf8(cp949_data:PoolByteArray):
	#Cp949.decode_cp949(cp949_data) #
	return cp949_data.get_string_from_ascii()

func parse_cp949(buffer):
	var length = buffer.get_u8()
	var cp949_data = PoolByteArray()
	for _i in range(length):
		var chr = buffer.get_u8()
		if chr !=0:
			cp949_data.append(chr)
	return cp949_to_utf8(cp949_data)
	
func parse_rmd(kind,buffer):
	var rmd = Rmd.new()
	rmd.kind = kind
	var filetype = parse_string(buffer)
	var file_number = buffer.get_u32()
	var padding = buffer.get_u32()
	
	padding = buffer.get_u32()
	
	var cp949str= parse_cp949(buffer)
	
	rmd.animation_parts = buffer.get_32()
	rmd.animation_entry_count = buffer.get_32()
	cp949str= parse_cp949(buffer)
	rmd.entry_count = buffer.get_32()
	
	for _i in range(rmd.entry_count):
		var entry = RmdEntry.new()
		entry.read(buffer)
		rmd.entries.append(entry)
		
	rmd.animation_count = buffer.get_32()
	for i in rmd.animation_count:
		var animation = RmdAnimation.new()
		animation.read(buffer)
		rmd.animations.append(animation)
	return rmd

func parse_rle(file_num,buffer):
	var resource_file = ResFile.new()
	if buffer.get_size()<14:
		return
	var file_type = buffer.get_utf8_string(14)
	if file_type!="Resource File":
		return
	#unknown_1: 4 Unknown bytes; (next free offset?)
	var tmp = buffer.get_u32()
	var total_res = buffer.get_u32()
	var res_offsets = []
	for idx in range(total_res):
		var offset = buffer.get_u32()
		res_offsets.append(offset)
	for index in range(len(res_offsets)):
		var offset = res_offsets[index]
		if offset!=0:
			var res = Res.new()
			res.index = index
			res.file_num = file_num
			res.read(offset,buffer)
			resource_file.resources.append(res)
	return resource_file
			
func parse_event_entry(buffer):
	var event_type = buffer.get_u16()
	#print("event_type:",event_type)
	if event_type != 0x44 || event_type != 0x60EA:
		return
	var event_unknown = buffer.get_32()
	print("event_unknown:",event_unknown)
	var event_count = buffer.get_32()
	for idx in event_count:
		var action_timeout = buffer.get_32()
		var trigger_string = parse_cp949(buffer)
		print("trigger_string:",trigger_string)
		var pos = buffer.get_position()
		var byte = buffer.get_u8()
		if byte!=0:
			buffer.seek(pos)
		var cont = true
		while(cont):
			var action_string = parse_cp949(buffer)
			print("action_string:",action_string)
			pos = buffer.get_position()
			byte = buffer.get_u8()
			if byte<=1 or byte==0x44 or byte==0x60:
				cont = false
			buffer.seek(pos)
	pass

func parse_rmi(buffer):
	var rmi = Rmi.new()
	var file_header = parse_string(buffer)
	#print("file_header:",file_header)
	var count = buffer.get_32()
	for idx in range(count):
		parse_event_entry(buffer)

func parse_rmm(buffer):
	var map = Map.new()
	var file_head = parse_string(buffer)
	if file_head != "RedMoon MapData 1.0":
		return
	map.size_x = buffer.get_u32()
	map.size_y = buffer.get_u32()
	map.id_count = buffer.get_u8()
	for idx in range(map.id_count):
		map.id_list.append(buffer.get_u8())
	map.name = cp949_to_utf8(map.id_list)
	map.number = buffer.get_u32()
	map.event_count = buffer.get_u32()
	
	for _i in range(map.event_count):
		var event = Event.new()
		event.read(buffer)
		if event.number!=0:
			map.events.append(event)
	var count = map.size_x * map.size_y
	for _i in range(count):
		#print(">>>>>",_i)
		var tile = MapTile.new()
		tile.read(buffer)
		map.tiles.append(tile)
	return map
func parse_lst(buffer):
	var filetype = parse_string(buffer)
	var version = parse_string(buffer)
	var list = List.new()
	list.read(buffer,version)
	return list
	
func parse_file(path,ex_data=null):
	var ext = path.get_extension()
	if ext=="lst":
		return parse_lst(getBuffer(path))
	elif ext=="rmm":
		return parse_rmm(getBuffer(path))
	elif ext=="rmi":
		return parse_rmi(getBuffer(path))
	elif ext=="rmd":
		return parse_rmd(ex_data,getBuffer(path))
	elif ext=="rle":
		return parse_rle(ex_data,getBuffer(path))

func createEntry(number,index):
	var entry = Entry.new()
	entry.file = number
	entry.index = index
	return entry
	
func createSprite(type,entry,width,height,offsetX,offsetY,image_raw):
	var sprite = RSprite.new()
	sprite.type = type
	sprite.rle_entry = entry
	sprite.x_dim=width
	sprite.y_dim=height
	sprite.x_off=offsetX
	sprite.y_off=offsetY
	sprite.image_raw=image_raw
	return sprite
func createSpriteEntry(sprite,texture):
	var entry = SpriteEntry.new()
	entry.sprite = sprite
	entry.texture = texture
	return entry
