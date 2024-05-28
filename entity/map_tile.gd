extends Object
var Entry = preload("res://entity/entry.gd")
var obj_rmd_entry
var tle_rmd_entry
var warp
var collision


func read(buffer):
	var b_0= buffer.get_u8()
	var b_1= buffer.get_u8()
	var b_2= buffer.get_u8()
	var b_3= buffer.get_u8()
	var b_4= buffer.get_u8()
	var b_5= buffer.get_u8()
	var b_6= buffer.get_u8()
	var b_7= buffer.get_u8()
	var obj_file_num = (b_0 / 4) + (b_1 % 32) * 64
	var tle_file_idx = ((b_2 % 128) * 8) + (b_1 / 32)
	var tle_file_num = (b_3 * 2) + (b_2 / 128)
	
	var warp = b_4
	var collision = b_6
	var obj_file_idx = b_7 << 1 if collision % 24 ==0 else (b_7 << 1) + 1
	obj_rmd_entry = Entry.new()
	obj_rmd_entry.file = obj_file_num
	obj_rmd_entry.index = obj_file_idx
	#print(obj_file_num," ",tle_file_idx," ",tle_file_num," ",obj_file_idx," ",tle_file_idx)
	
	tle_rmd_entry = Entry.new()
	tle_rmd_entry.file = tle_file_num
	tle_rmd_entry.index = tle_file_idx
	warp = warp
	collision = collision
