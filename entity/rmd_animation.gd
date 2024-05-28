extends Object
var frame_count=0
var frames=[]
var name = ""
func read(buffer):
	frame_count = buffer.get_32()
	for _i in range(frame_count):
		frames.append(buffer.get_16())
	
