extends Node
var Enums = preload("res://parser/enums.gd")
var data_path = "res://data/rles"
var bul_map={}
var ico_map={}
var chr_map={}
var obj_map={}
var tle_map={}
var int_map={}
var chr0_map={}
var chr1_map={}
var chr2_map={}
var chr3_map={}
var chr4_map={}
var chr5_map={}
var chr6_map={}
var chr7_map={}
var chr8_map={}
var chr9_map={}
var chr_etc_map={}
var texturesCaches={}
var _thread = Thread.new()
var data_config = {
	Enums.SpriteType.Bullet:"Bul/bul%05d.rle",
	Enums.SpriteType.Icon:"Ico/ico%05d.rle",
	Enums.SpriteType.Chr0:"Chr/C00/c00%05d.rle",
	Enums.SpriteType.Chr1:"Chr/C01/c01%05d.rle",
	Enums.SpriteType.Chr2:"Chr/C02/c02%05d.rle",
	Enums.SpriteType.Chr3:"Chr/C03/c03%05d.rle",
	Enums.SpriteType.Chr4:"Chr/C04/c04%05d.rle",
	Enums.SpriteType.Chr5:"Chr/C05/c05%05d.rle",
	Enums.SpriteType.Chr6:"Chr/C06/c06%05d.rle",
	Enums.SpriteType.Chr7:"Chr/C07/c07%05d.rle",
	Enums.SpriteType.Chr8:"Chr/C08/c08%05d.rle",
	Enums.SpriteType.Chr9:"Chr/C09/c09%05d.rle",
	Enums.SpriteType.Etc:"Chr/Etc/etc%05d.rle",
	Enums.SpriteType.Obj:"Obj/obj%05d.rle",
	Enums.SpriteType.Tile:"Tle/tle%05d.rle",
	Enums.SpriteType.Interface:"Int/int%05d.rle"
	}
func get_sprite_entry(entry,sprite_type):
	var sprite = req_sprite(entry,sprite_type)
	if sprite==null:
		sprite = load_sprite(entry.file,sprite_type)
		sprite = req_sprite(entry,sprite_type)
	return sprite

func get_bounding_rect(points: Array) -> Rect2:
	if points.size() == 0:
		return Rect2()

	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y

	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.x > max_x:
			max_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.y > max_y:
			max_y = point.y
	var rect_position = Vector2(min_x, min_y)
	var rect_size = Vector2(max_x - min_x+1, max_y - min_y+1)
	return Rect2(rect_position, rect_size)
	
func createTexture(img,item):
	var _sprite = SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Obj)
	var img_rect = Rect2(0,0,_sprite.sprite.x_dim,_sprite.sprite.y_dim)
	var img_x_1_off = img.source_x1 - _sprite.sprite.x_off
	var img_y_1_off = img.source_y1 - _sprite.sprite.y_off
	#print("===0:%s %s %s %s %s" % [item.id,img_x_1_off,img_y_1_off,img.source_width-_sprite.sprite.x_off,img.source_height-_sprite.sprite.y_off])
	var points=[]
	points.append(Vector2(img_x_1_off,img_y_1_off))
	points.append(Vector2(img.source_width-_sprite.sprite.x_off,img.source_height-_sprite.sprite.y_off))
	var src_rect = self.get_bounding_rect(points)
	var _x_diff = 0
	var _y_diff = 0
	#print("===1:%s %s" % [item.id,src_rect])
	if src_rect.intersects(img_rect):
		var rect = src_rect.clip(img_rect)
		if img_x_1_off <0:
			_x_diff = - img_x_1_off
		if img_y_1_off <0:
			_y_diff = -img_y_1_off
		src_rect = rect
	#print("===2:%s %s" % [item.id,src_rect])
	var dst_rect = Rect2(_x_diff,_y_diff,src_rect.size.x,src_rect.size.y)
	#print("===3:%s %s" % [item.id,dst_rect])
	var texture = _sprite.blit_rect(src_rect,dst_rect)
	return texture

func getTextureRect(img,item):
	var _sprite = SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Obj)
	var img_rect = Rect2(0,0,_sprite.sprite.x_dim,_sprite.sprite.y_dim)
	var img_x_1_off = img.source_x1 - _sprite.sprite.x_off
	var img_y_1_off = img.source_y1 - _sprite.sprite.y_off
	#print("===0:%s %s %s %s %s" % [item.id,img_x_1_off,img_y_1_off,img.source_width-_sprite.sprite.x_off,img.source_height-_sprite.sprite.y_off])
	var points=[]
	points.append(Vector2(img_x_1_off,img_y_1_off))
	points.append(Vector2(img.source_width-_sprite.sprite.x_off,img.source_height-_sprite.sprite.y_off))
	var src_rect = self.get_bounding_rect(points)
	var _x_diff = 0
	var _y_diff = 0
	#print("===1:%s %s" % [item.id,src_rect])
	if src_rect.intersects(img_rect):
		var rect = src_rect.clip(img_rect)
		if img_x_1_off <0:
			_x_diff = - img_x_1_off
		if img_y_1_off <0:
			_y_diff = -img_y_1_off
		src_rect = rect
	#print("===2:%s %s" % [item.id,src_rect])
	var dst_rect = Rect2(_x_diff + img.dest_x,_y_diff+img.dest_y,src_rect.size.x,src_rect.size.y)
	var result = {}
	result["src_rect"] = src_rect
	result["dst_rect"] = dst_rect
	return result
	
func req_sprite(entry,sprite_type):
	var id = entry.entry_id()
	match sprite_type:
		Enums.SpriteType.Bullet:
			return bul_map.get(id)
		Enums.SpriteType.Icon:
			return ico_map.get(id)
		Enums.SpriteType.Chr0:
			return chr0_map.get(id)
		Enums.SpriteType.Chr1:
			return chr1_map.get(id)
		Enums.SpriteType.Chr2:
			return chr2_map.get(id)
		Enums.SpriteType.Chr3:
			return chr3_map.get(id)
		Enums.SpriteType.Chr4:
			return chr4_map.get(id)
		Enums.SpriteType.Chr5:
			return chr5_map.get(id)
		Enums.SpriteType.Chr6:
			return chr6_map.get(id)
		Enums.SpriteType.Chr7:
			return chr7_map.get(id)
		Enums.SpriteType.Chr8:
			return chr8_map.get(id)
		Enums.SpriteType.Chr9:
			return chr9_map.get(id)
		Enums.SpriteType.Etc:
			return chr_etc_map.get(id)
		Enums.SpriteType.Obj:
			return obj_map.get(id)
		Enums.SpriteType.Tile:
			return tle_map.get(id)
		Enums.SpriteType.Interface:
			return int_map.get(id)

func load_sprite(number,sprite_type):
	var path=data_path.plus_file(data_config[sprite_type] % [number])
	var resource_file = Parsing.parse_file(path,number)
	for res in resource_file.resources:
		var entry = Parsing.createEntry(number,res.index)
		var sprite = Parsing.createSprite(sprite_type,entry,res.width,res.height,res.offset_x,res.offset_y,res.image_raw)
		var img = Image.new()
		img.create_from_data(res.width,res.height,false,Image.FORMAT_RGBA8,res.image_raw)
		var texture = SpriteFrame.new()
		texture.create_from_image(img)
		texture.offset=Vector2(res.offset_x,res.offset_y)
		var spriteEntry = Parsing.createSpriteEntry(sprite,texture)
		var storeKey = entry.entry_id()
		match sprite_type:
			Enums.SpriteType.Bullet:
				bul_map[storeKey] = spriteEntry
			Enums.SpriteType.Icon:
				ico_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr0:
				chr0_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr1:
				chr1_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr2:
				chr2_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr3:
				chr3_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr4:
				chr4_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr5:
				chr5_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr6:
				chr6_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr7:
				chr7_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr8:
				chr8_map[storeKey] = spriteEntry
			Enums.SpriteType.Chr9:
				chr9_map[storeKey] = spriteEntry
			Enums.SpriteType.Etc:
				chr_etc_map[storeKey] = spriteEntry
			Enums.SpriteType.Obj:
				obj_map[storeKey] = spriteEntry
			Enums.SpriteType.Tile:
				tle_map[storeKey] = spriteEntry
			Enums.SpriteType.Interface:
				int_map[storeKey] = spriteEntry
	
	
