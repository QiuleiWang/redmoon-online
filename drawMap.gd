extends Node2D
var drawGround=[]
var drawObject=[]
var shadows = []
var tile_height = 24
var tile_width = 48
var testTexture
func addDrawGround(texture):
	drawGround.append(texture)
	
func addShadows(texture):
	shadows.append(texture)

func fix_srcRect_dst_rect(texture_size, src_rect, dst_rect):
	var r_clipped_src_rect = Rect2()
	var r_clipped_dest_rect = Rect2()
	
	# Initialize the positions and sizes
	r_clipped_dest_rect.position = dst_rect.position
	r_clipped_src_rect.position = src_rect.position
	r_clipped_src_rect.size = src_rect.size
	
	# Clip src_rect if it is out of the texture bounds (left and top)
	if r_clipped_src_rect.position.x < 0:
		r_clipped_dest_rect.position.x -= r_clipped_src_rect.position.x
		r_clipped_src_rect.size.x += r_clipped_src_rect.position.x
		r_clipped_src_rect.position.x = 0
		
	if r_clipped_src_rect.position.y < 0:
		r_clipped_dest_rect.position.y -= r_clipped_src_rect.position.y
		r_clipped_src_rect.size.y += r_clipped_src_rect.position.y
		r_clipped_src_rect.position.y = 0

	# Clip dst_rect if it is out of the texture bounds (left and top)
	if r_clipped_dest_rect.position.x < 0:
		r_clipped_src_rect.position.x -= r_clipped_dest_rect.position.x
		r_clipped_src_rect.size.x += r_clipped_dest_rect.position.x
		r_clipped_dest_rect.position.x = 0
		
	if r_clipped_dest_rect.position.y < 0:
		r_clipped_src_rect.position.y -= r_clipped_dest_rect.position.y
		r_clipped_src_rect.size.y += r_clipped_dest_rect.position.y
		r_clipped_dest_rect.position.y = 0
	
	# Clip src_rect size based on texture size and dst_rect size
	r_clipped_src_rect.size.x = max(0, min(r_clipped_src_rect.size.x, texture_size.x - r_clipped_src_rect.position.x))
	r_clipped_src_rect.size.x = min(r_clipped_src_rect.size.x, dst_rect.size.x)

	r_clipped_src_rect.size.y = max(0, min(r_clipped_src_rect.size.y, texture_size.y - r_clipped_src_rect.position.y))
	r_clipped_src_rect.size.y = min(r_clipped_src_rect.size.y, dst_rect.size.y)
	
	# Update the destination rectangle size to match the clipped source rectangle size
	r_clipped_dest_rect.size = r_clipped_src_rect.size
	
	return [r_clipped_src_rect, r_clipped_dest_rect]


	
	
func addDrawObject(obj):
	var src_rect = obj["src_rect"]
	var dst_rect = obj["dst_rect"]
	var texture_source = obj["texture"]
	var rects = fix_srcRect_dst_rect(texture_source.get_size(),src_rect,dst_rect)
	src_rect = rects[0]
	dst_rect = rects[1]
	if src_rect.has_no_area() or dst_rect.has_no_area():
		return
		
#	if src_rect.position.x<0 or src_rect.position.y<0 or src_rect.end.x>texture_source.get_width() or src_rect.end.y>texture_source.get_height():
#		return
#	if dst_rect.position.x<0 or dst_rect.position.y<0 or dst_rect.end.x>texture_source.get_width() or dst_rect.end.y>texture_source.get_height():
#		return
	drawObject.append(obj)
	
func clear():
	drawGround.clear()
	drawObject.clear()
	for child in get_children():
		child.queue_free()

func _draw():
	for data in drawGround:
		self.draw1(data["texture"],data["src_rect"],data["dst_rect"],data["position"],0)
	for data in drawObject:
		self.draw1(data["texture"],data["src_rect"],data["dst_rect"],data["position"],data["zorder"])
	
func draw1(texture_source,srcRect,dstRect,pos,zorder):
	#第一种绘制方式
#	var src_image = texture_source.get_data()
#	var resized_image = Image.new()
#	resized_image.create(dstRect.size.x + dstRect.position.x,dstRect.size.y+dstRect.position.y,false,Image.FORMAT_RGBA8)
#	resized_image.blit_rect(texture_source.image,srcRect,dstRect.position)
#	var texture = ImageTexture.new()
#	texture.create_from_image(resized_image)
#	#texture 需要在别的地方引用下,才能绘制出来
#	var rsprite = Sprite.new()
#	rsprite.texture = texture
#	rsprite.position = Vector2(pos.x*tile_width,pos.y*tile_height)
#	rsprite.z_index = zorder
#	add_child(rsprite)
#	#draw_texture(texture,Vector2(pos.x*tile_width,pos.y*tile_height))

	#第二种绘制方式
	#var rects = fix_srcRect_dst_rect(texture_source.get_size(),src1Rect,dst1Rect)
	#var srcRect = rects[0]
	#var dstRect = rects[1]
#	if srcRect.has_no_area() or dstRect.has_no_area():
#		return
		
	var rect = Rect2()
	rect.position = Vector2(pos.x*tile_width + dstRect.position.x,pos.y*tile_height + dstRect.position.y)
	rect.size = dstRect.size
	draw_texture_rect_region(texture_source,rect,srcRect,Color(1,1,1,1),false,null,true)
	
	#第三种方式
#	var sprite = Sprite.new()
#	sprite.texture = texture_source
#	sprite.region_enabled = true
#	sprite.region_rect = srcRect
#	sprite.offset = dstRect.position
#	sprite.centered = false
#	sprite.position = Vector2(pos.x*tile_width,pos.y*tile_height)
#	sprite.z_index = zorder
#	add_child(sprite)

class MyObjectSort:
	static func _sort(a, b):
		if b["zorder"] > a["zorder"]:
			return true
		return false
	
