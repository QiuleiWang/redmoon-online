extends Object
var name=""
var file_number=0
var resources = []

func serialize():
	return {name=name,file_number=file_number}
