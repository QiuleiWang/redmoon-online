enum RmdType {Bullet,Character,Icon,Obj,Tile}
enum SpriteType {
	Chr0,
	Chr1,
	Chr2,
	Chr3,
	Chr4,
	Chr5,
	Chr6,
	Chr7,
	Chr8,
	Chr9,
	Etc,
	Bullet,
	Icon,
	Obj,
	Tile,
	Interface
	}
enum ListType {
	Chr0,
	Chr1,
	Chr2,
	Chr3,
	Chr4,
	Chr5,
	Chr6,
	Chr7,
	Chr8,
	Chr9,
	Etc,
	Bullet,
	Icon,
	Interface,
	Sound,
	Tile,
	Obj
}

enum DrawType {
	Character=32,
	Shadow=64,
	Hair=512, #头发
	clothing = 1024, #衣服
}

enum EntryType {
	End = 0,
	Paint = 1,
	MoveX = 2,
	NextLine = 3,
}
