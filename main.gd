extends Control
onready var itemList = $left/ItemList
onready var gridContainer = $right/ItemList
onready var menu = $MenuButton
onready var tree = $Tree
onready var animatioin = $animation
var ItemScene = preload("res://item.tscn")
var Enums = preload("res://parser/enums.gd")
var counter_thread
func loadrle_Res(node,path):
	var resource_file = Parsing.parse_file(path,29)
	print(resource_file.serialize())
	var spriteFrames = SpriteFrames.new()
	spriteFrames.add_animation("idle")
	for res in resource_file.resources:
		var img = Image.new()
		img.create_from_data(res.width,res.height,false,Image.FORMAT_RGBA8,res.image_raw)
		var texture = ImageTexture.new()
		texture.create_from_image(img)
		#texture.offset=Vector2(res.offset_x,res.offset_y)
		spriteFrames.add_frame("idle",texture)
	node.frames=spriteFrames
	node.play("idle")

func scan_dir(path):
	var file_name
	var files = []
	var dir = Directory.new()
	var error = dir.open(path)
	if error!=OK:
		print("Can't open "+path+"!")
		return
	dir.list_dir_begin(true,true)
	file_name = dir.get_next()
	while file_name!="":
		if dir.current_is_dir():
			var new_path = path+"/"+file_name
			files += scan_dir(new_path)
		else:
			var name = path+"/"+file_name
			files.push_back(name.replace("res://data/",""))
		file_name = dir.get_next()
	dir.list_dir_end()
	return files

func add_file_to_item(p_item:TreeItem,p_name:String):
	var pp = p_name.find("/")
	if(pp==-1):
		var item= tree.create_item(p_item)
		item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
		item.set_checked(0, true)
		#item.set_editable(0, true)
		item.set_text(0, p_name)
		#item.set_text(1,"".humanize_size(p_size))
		item.set_collapsed(true)
	else:
		var dir_name = p_name.substr(0,pp)
		var path= p_name.substr(pp+1,p_name.length())
		var childItem = p_item.get_children()
		while(childItem):
			if childItem.get_text(0) == dir_name:
				add_file_to_item(childItem,path)
				return
			childItem=childItem.get_next()
		var item = tree.create_item(p_item)
		item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
		item.set_checked(0, true)
		#item.set_editable(0, true)
		item.set_text(0, dir_name)
		item.set_collapsed(true)
		add_file_to_item(item,path)
		
func load_Sprites(parmter):
	var entrys=parmter[0]
	var type = parmter[1]
	var count = 0
	for entry in entrys:
		#print("load success:",count," file:",entry.file," index:",entry.index)
		var sprite=SpriteMgr.get_sprite_entry(entry,type)
		count+=1
		 
func all_character():
	var characters=[]
	for i in range(10):
		characters.append({name="ch"+str(i),data=DataMgr.getCharacter(i)})
	characters.append({name="etc",data=DataMgr.getCharacter(10)})
	return characters
	
func charaterParse(id):
	var list = ListMgr.get_list(id)
	var data = DataMgr.get_data(Enums.RmdType.Character,id)
	var animations = data.animations
	var spriteFrames = SpriteFrames.new()
	spriteFrames.add_animation("idle")
	print("animation_parts:",data.animation_parts,"animation_entry_count:",data.animation_entry_count)
	for aniIndex in range(len(animations)):
		var ani=animations[aniIndex]
		if ani.frame_count>0:
			for frame in range(ani.frame_count):
				var frameid =ani.frames[frame]
				#动画帧数
				var rmd_entry = data.entries[frameid]
				#每帧的图片(角色，阴影，和一些别的部件,头发什么的)
				for i in range(rmd_entry.image_count):
					var rmd_img = rmd_entry.images[i]
					for img_id in rmd_img.image_id:
						var item = list.get_item(img_id)
#						var spriteEntry = SpriteMgr.get_sprite_entry(item.entry,id)
#						var iitem = ItemScene.instance()
#						iitem.get_node("Sprite").texture=spriteEntry.texture
#						iitem.get_node("info").text = str(aniIndex) + ":" +str(frame) + ":" +str(rmd_img.render_z)
#						gridContainer.add_child(iitem)
						#itemList.add_item(str(imgConfig.render_z),spriteEntry.texture)
						#spriteFrames.add_frame("idle",spriteEntry.texture)
func add_tree_item(parentItem,text,meta_data):
	var item= tree.create_item(parentItem)
	item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
	item.set_checked(0, true)
	item.set_text(0, text)
	item.set_collapsed(true)
	item.set_metadata(0,meta_data)
	return item
	
func _ready():
	print("xxx:",0x01<<4)
	counter_thread = Thread.new()
	var root = tree.create_item()
	root.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
	root.set_checked(0,true)
	root.set_text(0,"character")
	root.set_metadata(0,"")
	var character = all_character()
	for cha in character:
		var item = add_tree_item(root,cha.name,null)
		var animation = cha.data.getAllAnimation()
		for ani in animation:
			add_tree_item(item,ani.name,{rmd=cha.data,ani=ani})
			
	#var list = Parsing.parse_file("res://data/rles/Chr/etc.lst")
	#charaterParse(1)
#	var data = DataMgr.get_data(Enums.RmdType.Character,0)
#	print(data.string,":",data.animation_parts)
	#counter_thread.start(self, "count", [10])
#	var map_id = 3
#	MapMgr.load_map(map_id)
#	var tile_sprite_Objcts = []
#	var map = MapMgr.get_map(map_id)
#	var tile_x = 0
#	var tile_y = 0
#	var tile_stride = map.size_x
#	var obj_list = ListMgr.get_list(Enums.ListType.Obj)
#	var tle_list = ListMgr.get_list(Enums.ListType.Tile)
#	for tile in map.tiles:
#		var obj_entry = tile.obj_rmd_entry
#		if obj_entry.file!=0:
#			var file = obj_entry.file
#			var index = obj_entry.index
#			var rmd = DataMgr.get_data(Enums.RmdType.Obj,file)
#			var entry = rmd.get_entry(index)
#			if entry:
#				for img in entry.images:
#					for id in img.image_id:
#						var item = obj_list.get_item(id)
#						tile_sprite_Objcts.append(item.entry)
#						#print(item.entry.serialize())
#						#var sprite = SpriteMgr.get_sprite_entry(item.entry,Enums.SpriteType.Obj)
#			for ani in rmd.animations:
#				print(ani)
#	counter_thread.start(self, "load_Sprites", [tile_sprite_Objcts,Enums.SpriteType.Obj])
	#counter_thread.start(self,"test")
#	var list = Parsing.parse_file("res://data/rles/Chr/c00.lst")
#	print(list.serialize())
#	#var obj = Parsing.parse_rmd(Enums.RmdType.Character,"res://data/chr00000.rmd")
#
#	loadrle_Res($root/shadow,"res://data/rles/Obj/obj00029.rle")
#	loadrle_Res($root/AniSprite,"res://data/rles/Chr/C00/c0000035.rle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _popup_selected(index):
	print("_popup_selected:",index)

func _on_MenuButton_pressed():
	menu.get_popup().clear()
	menu.get_popup().add_item("open file")
	menu.get_popup().add_item("save file")
	menu.get_popup().connect("index_pressed",self,"_popup_selected")
	pass # Replace with function body.


func _on_Tree_item_selected():
	var item = tree.get_selected()
	var meta_data = item.get_metadata(0)
	if meta_data:
		animatioin.setAnimation(meta_data)


func _on_Button_pressed():
	var anis = animatioin.animations
	var aniName = animatioin.actionName
	var outPath = "C:\\Users\\Administrator\\Desktop\\output"
	var dir = Directory.new()
	var outDir = outPath.plus_file(aniName)
	if not dir.dir_exists(outDir):
		dir.make_dir(outDir)
	for frames in anis:
		for frame_data in frames:
			var frame = frame_data.frame
			var children = frame.get_children()
			for cindex in range(len(children)):
				var sprite = children[cindex]
				sprite.texture.get_data().save_png(outDir.plus_file(sprite.name+".png"))
	


func _on_dirtionBt_pressed():
	animatioin.setDirection(animatioin.direction+1)
