extends Object
var name
var id
var entry

func serialize():
	return {name=name,id=id,entry=entry.serialize()}
