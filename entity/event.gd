extends Object
var number=0
var left=0
var top=0
var right=0
var bottom=0

func read(buffer):
	number = buffer.get_u16()
	left = buffer.get_u32()
	top = buffer.get_u32()
	right = buffer.get_u32()
	bottom = buffer.get_u32()
