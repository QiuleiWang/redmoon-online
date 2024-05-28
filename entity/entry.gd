extends Object
var file
var index
func serialize():
	return {file = file,index=index}

func entry_id():
	return str(file)+"_"+str(index)
