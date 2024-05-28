extends Object
var RmdEntry =preload("res://entity/rmd_entry.gd")
var kind
var string=""
var animation_parts=0
var animation_entry_count=0
var entry_count=0
var entries=[]
var animation_count=0
var animations=[]
var animationcfg=[["walk",8],["run",8],["attack1",8],["attack2",8],["hurt1",8],["hurt2",8],["idle",8],["other",-1]]
func get_entry(index):
	if index<len(entries):
		return entries[index]
	else:
		return null
#过滤动画
func getAllAnimation():
	var anis=[]
	for aniIndex in range(len(animations)):
		var ani=animations[aniIndex]
		if ani.frame_count>0:
			ani.name=len(anis)
			anis.append(ani)
	var new_anis=[]
	var curIndex=0
	for index in len(animationcfg):
		if curIndex>=len(anis):
			break
		var cfg = animationcfg[index]
		var ani = {}
		ani.name = cfg[0]
		var asa = []
		var number=cfg[1]
		if number==-1:
			number=len(anis)-curIndex
		for i in range(number):
			asa.append(anis[curIndex])
			curIndex+=1
		ani.animation=asa
		new_anis.append(ani)
	return new_anis
		
func serialize():
	return {
	animation_parts = animation_parts,
	animation_entry_count=animation_entry_count,
	entry_count=entry_count,
	animation_count=animation_count
	}
