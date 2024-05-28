extends Node
var RmdImage =preload("res://entity/rmd_image.gd")
var image_count=0
var images=[]

func read(buffer):
	image_count = buffer.get_32()
	for _j in range(image_count):
		var img = RmdImage.new()
		img.read(buffer)
		images.append(img)

