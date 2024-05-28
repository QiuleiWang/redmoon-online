extends Node2D
var Enums = preload("res://parser/enums.gd")
var drawObjects = []
var thread: Thread = Thread.new()
var draw_rect: Rect2
var is_drawing: bool = false
var mapID = 1
var tile_height = 24
var tile_width = 48
var tile_x = 0
var tile_y = 0
var velocity = Vector2.ZERO
var lastRect = null
var mapFinish =false
var mutex = Mutex.new()
var mapObjCache = {}
var mapTileCache = {}
var mapWidth = 256
func load_tiles(tle_list,map_tile):
	var tle_entry = map_tile.tle_rmd_entry
	if tle_entry.file!=0:
		var file = tle_entry.file
		var index = tle_entry.index
		var rmd = DataMgr.get_data(Enums.RmdType.Tile,file)
		if rmd:
			var entry = rmd.get_entry(index)
			if entry:
				for img in entry.images:
					for id in img.image_id:
						var item = tle_list.get_item(id)
						SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Tile)
	
func load_objs(obj_list,map_tile):
	var obj_entry = map_tile.obj_rmd_entry
	if obj_entry.file!=0:
		var file = obj_entry.file
		var index = obj_entry.index
		var rmd = DataMgr.get_data(Enums.RmdType.Obj,file)
		if rmd:
			var entry = rmd.get_entry(index)
			if entry:
				for img in entry.images:
					for id in img.image_id:
						var item = obj_list.get_item(id)
						SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Obj)
						
func _load_map_in_thread():
	MapMgr.load_map(mapID)
	var map = MapMgr.get_map(mapID)
	var obj_list = ListMgr.get_list(Enums.ListType.Obj)
	var tle_list = ListMgr.get_list(Enums.ListType.Tile)
#	for map_tile in map.tiles:
#		self.load_tiles(tle_list,map_tile)
#		self.load_objs(obj_list,map_tile)
		
	call_deferred("_notify_main_thread")

func _notify_main_thread():
	mapFinish = true
	thread.wait_to_finish()
	
	
func _ready():
	#var list = Parsing.parse_file("res://data/rles/Chr/etc.lst")
	#charaterParse(1)
#	var data = DataMgr.get_data(Enums.RmdType.Character,0)
#	print(data.string,":",data.animation_parts)
	#counter_thread.start(self, "count", [10])
	thread.start(self, "_load_map_in_thread")
	
func handle_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * 120
	

func move_player(delta):
	$player.position += velocity * delta

func drawObj(obj_list,offset,map_tile):
	var obj_entry = map_tile.obj_rmd_entry
	if obj_entry.file!=0:
		var file = obj_entry.file
		var index = obj_entry.index
		var rmd = DataMgr.get_data(Enums.RmdType.Obj,file)
		if rmd:
			var entry = rmd.get_entry(index)
			if entry:
				var objs= {"children":[]}
				var zorder = 0
				var indexZ=0
				for img_index in entry.images.size():
					var img = entry.images[img_index]
					for id in img.image_id:
						var key = str(offset.x + offset.y*self.mapWidth) + "_"+str(id)
						var result = mapObjCache.get(key)
						if result==null:
							var item = obj_list.get_item(id)
							var _sprite = SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Obj)
							result = SpriteMgr.getTextureRect(img,item)
							#var p = Vector2(offset.x+img.dest_x ,offset.y+img.dest_y)
							result["position"] = offset
							result["texture"] = _sprite.texture
							print("img.render_zimg.render_z:",img.render_z," : ",img.draw_type)
							print(item.serialize())
							print("id:",id," ",offset.x + offset.y*self.mapWidth - img.render_z," offset:",offset)
							result["zorder"] = offset.x +offset.y  + indexZ
							mapObjCache[key] = result
							zorder = max(zorder,img.render_z)
							indexZ+=1
						var src_rect = result["src_rect"]
						var dst_rect = result["dst_rect"]
						var texture_source = result["texture"]
						$map.addDrawObject(result)
					
						

func drawTile(tileList,offset,map_tile):
	var tle_entry = map_tile.tle_rmd_entry
	if tle_entry.file!=0:
		var file = tle_entry.file
		var index = tle_entry.index
		var rmd = DataMgr.get_data(Enums.RmdType.Tile,file)
		if rmd:
			var entry = rmd.get_entry(index)
			if entry:
				for img in entry.images:
					for id in img.image_id:
						var key = str(offset.x*self.mapWidth + offset.y) + "_"+str(id)
						var result = mapTileCache.get(key)
						if result==null:
							var item = tileList.get_item(id)
							var _sprite = SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Tile)
							var _w = img.source_width - img.source_x1
							var _h = img.source_height - img.source_y1
							var src_rect = Rect2(img.source_x1,img.source_y1,_w,_h)
							var dst_rect = Rect2(0,0,tile_width,tile_height)
							#var texture = _sprite.blit_rect(src_rect,dst_rect)
							result = {}
							result["src_rect"] = src_rect
							result["dst_rect"] = dst_rect
							result["texture"] = _sprite.texture
							result["position"] = offset
							mapTileCache[key]= result
						$map.addDrawGround(result)
						
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.handle_input()
	self.move_player(delta)
	var viewport = get_viewport()
	var viewSize = viewport.size*1.5
	var camera = $player/camera
	var screen_rect = Rect2(camera.get_camera_screen_center() - viewSize / 2, viewSize)
	if self.lastRect == screen_rect or mapFinish==false:
		return

	var map = MapMgr.get_map(mapID)
	var tile_stride = map.size_x
	self.mapWidth = tile_stride
	var map_tiles = map.tiles
	var obj_list = ListMgr.get_list(Enums.ListType.Obj)
	var tle_list = ListMgr.get_list(Enums.ListType.Tile)
	var tile_count = map.tiles.size()
	var y_min = max(0,int(floor(screen_rect.position.y / tile_height)))
	var y_max = int(floor(screen_rect.size.y/tile_height) + y_min)

	var x_min = max(0,int(floor(screen_rect.position.x / tile_width)))
	var x_max = int(floor(screen_rect.size.x/tile_width) + x_min)

	$map.clear()
	for x in range(x_min,x_max):
		for y in range(y_min,y_max):
			var index = y * tile_stride + x
			if index<tile_count:
				var offset = Vector2(x,y)
				var map_tile = map_tiles[index]
				self.drawTile(tle_list,offset,map_tile)
				self.drawObj(obj_list,offset,map_tile)
	self.lastRect = screen_rect
	$map.update()


var rowY = 5
func _on_next_row_pressed():
	rowY +=1
	var map = MapMgr.get_map(mapID)
	var tile_stride = map.size_x
	self.mapWidth = tile_stride
	var map_tiles = map.tiles
	var obj_list = ListMgr.get_list(Enums.ListType.Obj)
	var tle_list = ListMgr.get_list(Enums.ListType.Tile)
	var tile_count = map.tiles.size()
	var y_min = 5
	var y_max = rowY

	var x_min = 12
	var x_max = 14
#	var y=4
#	var x=rowY
#	var index = y * tile_stride + x
#	var offset = Vector2(x,y)
#	var map_tile = map_tiles[index]
#	self.drawTile(tle_list,offset,map_tile)
#	self.drawObj(obj_list,offset,map_tile)
	
	for y in range(y_min,y_max):
		for x in range(x_min,x_max):
			var index = y * tile_stride + x
			if index<tile_count:
				var offset = Vector2(x,y)
				var map_tile = map_tiles[index]
				self.drawTile(tle_list,offset,map_tile)
				self.drawObj(obj_list,offset,map_tile)
	$map.update()
	
