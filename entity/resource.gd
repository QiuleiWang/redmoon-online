extends Object
var Enums = preload("res://parser/enums.gd")
var file_num=0
var index=0
var offset=0
var length=0
var offset_x=0
var offset_y=0
var width=0
var height=0
var unknown_1=0
var unknown_2=0
var unknown_3=0
var unknown_4=0
var image_raw = []

func serialize():
	return {width=width,height=height,file_num = file_num,index=index,offset=offset,length=length,offset_x=offset_x,offset_y=offset_y}

func format_r5g6b5_norm(d):
	var b = ((d & 0x1F)/ 31.0) * 255
	var g = (((d >> 5) & 0x3F)/ 63.0) * 255
	var r = ((d >> 11) & 0x1F)/ 31.0 * 255
	return {r=r,g=g,b=b}
	
func read(offset,buffer):
	buffer.seek(offset)
	offset = offset
	length = buffer.get_u32()
	offset_x = buffer.get_32()
	offset_y = buffer.get_32()
	width = buffer.get_32()
	height = buffer.get_32()
	unknown_1 = buffer.get_u32()
	unknown_2 = buffer.get_u32()
	unknown_3 = buffer.get_u32()
	unknown_4 = buffer.get_u32()
	if width < 8000 and width >0 and height<8000 and height>0:
		var total_px = width * height *4
		for _i in range(total_px):
			image_raw.append(0x0)
	else:
		image_raw.append(0xFF) #R
		image_raw.append(0xFF) #G
		image_raw.append(0xFF) #B
		image_raw.append(0xFF) #A
		return
	var x = 0
	var y = 0
	while(true):
		var entry_type = buffer.get_u8()
		match entry_type:
			Enums.EntryType.End:
				return
			Enums.EntryType.Paint:
				var pixels = buffer.get_u32()
				for _p in range(pixels):
					var color = format_r5g6b5_norm(buffer.get_u16())
					var _y = y * 4 * width
					var _x = x * 4
					var idx = _y + _x
					image_raw[idx] = color.r
					image_raw[idx+1] = color.g
					image_raw[idx+2] = color.b
					image_raw[idx+3] = 0xFF
					x += 1
			Enums.EntryType.MoveX:
				x += buffer.get_32()/2
				
			Enums.EntryType.NextLine:
				y += 1
			_:
				print("other")
			
