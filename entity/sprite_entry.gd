extends Object
var sprite
var texture

func renderSprite(srcRect,dstRect):
	var rsprite = Sprite.new()
	rsprite.centered=true
	rsprite.texture = self.blit_rect(srcRect,dstRect)
	return rsprite

func blit_rect(srcRect,dstRect):
	var resized_image = Image.new()
	resized_image.create(srcRect.size.x+dstRect.position.x,srcRect.size.y+dstRect.position.y,false,Image.FORMAT_RGBA8)
	resized_image.blit_rect(self.texture.image,srcRect,dstRect.position)
	var texture = ImageTexture.new()
	texture.create_from_image(resized_image)
	return texture


	
	
