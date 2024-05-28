# RMD files are sort of data pointers for the Objects and
# Tiles and include things like which file they are in and
# if they are a part of an animation or so.
#
# [HEADER]
# String
# 12 empty bytes
# String
# int animation parts (this is for object animations)
# int animation rows
# String
# int rmd rows
#
# [RMD RowEntry]
# int ImageCount (How many images this row/entry contains,
#                 like an image from sadad for example can
#                 contain: Body, color hair, color body, weapon)
#
# [RMD RowEntry - Images]
# int SourceX      // upper-left  x coordinate
# int SourceY      // upper-right x coordinate
# int SourceWidth  // lower-left  y coordinate
# int SourceHeight // lower-right y coordinate
# int empty
# int renderz
# int DestX
# int DestY
# int Draw Type (Shadow, skill, normal)
# int ImageIDCount
#
# [RMD Row - Images - Image ID]
# int ImageID (Lst row pointer,
#              this is a array so different weapons can be used)
#
# int AnimationsCount
#
# [RMD Animation]
# int AnimationFrames
#
# [RMD Animation - Frame]
# int RMDRowPointer (points to a row of the RMD)

extends Object
var source_x1=0
var source_y1=0
var source_width=0
var source_height=0
var empty_1=0
var empty_2=0
var render_z=0
var dest_x=0
var dest_y=0
var draw_type=0 # enum{ Shadow, skill, normal }
var image_id_count=0
var image_id=[]   #Lst row/entry pointer entries

func serialize():
	return {draw_type=draw_type,source_x1 = source_x1,source_y1=source_y1,source_width=source_width,source_height=source_height,render_z=render_z,dest_x=dest_x,dest_y=dest_y}
func getDrawTypeText():
	if draw_type==0:
		return "Shadow"
	elif draw_type==1:
		return "skill"
	else:
		return "normal"

func read(buffer):
	image_id = []
	source_x1 = buffer.get_32()
	source_y1 = buffer.get_32()
	source_width = buffer.get_32()
	source_height = buffer.get_32()
	empty_1 = buffer.get_32()
	empty_2 = buffer.get_32()
	dest_x = buffer.get_32()
	dest_y = buffer.get_32()
	render_z = buffer.get_32()
	draw_type = buffer.get_32()
	image_id_count = buffer.get_32()
	for _k in range(image_id_count):
		image_id.append(buffer.get_32())
