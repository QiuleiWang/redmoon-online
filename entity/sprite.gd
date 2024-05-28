extends Object
var type
var rle_entry
var x_dim=0
var y_dim=0
var x_off=0
var y_off=0
var image_raw=[]

func serialize():
	return {x_dim=x_dim,y_dim=y_dim,x_off=x_off,y_off=y_off}
func getPosition():
	return Vector2(x_off,y_off)
