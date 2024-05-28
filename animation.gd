extends Control
var Enums = preload("res://parser/enums.gd")
var frame_index = 0
var frame_interval = 1
var _time = 0
var _frame = null
var _loop = true
var animations=[] #8个方向的动画数据
var direction = 0
var actionName=""
func setAnimation(aniObj):
	_time = 0
	animations=[]
	setFrame(null)
	var rmd = aniObj.rmd
	actionName = aniObj.ani.name
	for dir in len(aniObj.ani.animation):
		var ani=aniObj.ani.animation[dir]
		var frames = createAnimation(rmd,ani,dir)
		animations.append(frames)
func setDirection(dir):
	if dir>=len(animations):
		direction = 0
	else:
		direction = dir
func createAnimation(rmd,ani,dir):
	_time = 0
	var list = ListMgr.get_list(rmd.kind)
	var frames = []
	for frame in range(ani.frame_count):
#		if frame%2==0:
#			continue
		var frameid =ani.frames[frame]
		#动画帧数
		var rmd_entry = rmd.entries[frameid]
		#每帧的图片(角色，阴影，和一些别的部件,头发什么的)
		var frameNode = AnimationFrame.new()
		var info=""
		var chactorOffY=0
		#每帧图片数量
		for rmgIndex in range(len(rmd_entry.images)):
			var rmd_img = rmd_entry.images[rmgIndex]
			#image_id,图片id数组应该只有1个
			for img_id in rmd_img.image_id:
				var item = list.get_item(img_id)
				var spriteEntry = SpriteMgr.get_sprite_entry(item.entry,rmd.kind)
				var sprite = Sprite.new()
				sprite.centered=true
				#锚点为图形左下角
				var sprite_data = spriteEntry.sprite
				var height_diff = rmd_img.source_height - spriteEntry.texture.get_height()
				var resized_image = Image.new()
				resized_image.create(rmd_img.source_width,rmd_img.source_height,false,Image.FORMAT_RGBA8)
				var offset=Vector2(sprite_data.x_off,sprite_data.y_off)
#				if rmd_img.draw_type==Enums.DrawType.Character:
#					offset.y=offset.y-sprite_data.y_off
				offset.y = height_diff-offset.y
				#resized_image.blit_rect(spriteEntry.texture.image,Rect2(Vector2.ZERO,spriteEntry.texture.image.get_size()),offset)
				
				var texture = ImageTexture.new()
				texture.create_from_image(spriteEntry.texture.image)
				sprite.texture = texture
				sprite.z_index = -rmd_img.render_z
				sprite.name = str(rmgIndex)+"_"+str(dir) +"_"+str(frame)
				info+=str(sprite_data.serialize())
				info+="\n"
				info+=str(rmd_img.serialize())
				info+="\n"
				frameNode.addSpriteFrame(sprite,rmd_img.draw_type)
		frames.append({frame=frameNode,info=info})
	return frames

func setFrame(frame_data):
	if _frame:
		remove_child(_frame)
		_frame=null
	if frame_data:
		var frame = frame_data.frame
		_frame = frame
		add_child(_frame)
		$info.text=frame_data.info

func getCurrentAnimation():
	pass
func _process(delta):
	if direction>=len(animations):
		return
	var aniFrames=animations[direction]
	if frame_index<len(aniFrames):
		_time+=delta
		if _time>=frame_interval:
			_time=_time-frame_interval
			var frame = aniFrames[frame_index]
			setFrame(frame)
			#frame_index+=1
			if _loop and frame_index>=len(aniFrames):
				frame_index=0
				_time=0

		
