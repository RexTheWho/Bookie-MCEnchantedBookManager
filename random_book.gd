extends Node

const COLOR_COLORS = [
	Color.aqua,
	Color.rebeccapurple,
	Color.chartreuse,
	Color.crimson,
	Color.darkorange,
	Color.deeppink,
	Color.forestgreen,
	Color.gold,
	Color.lightseagreen,
	Color.royalblue,
	Color.yellowgreen,
]

const COVER_COLORS = []
const COVER = [
	preload("res://random_book/book_cover.png"),
#	preload("res://random_book/book_cover2.png"),
#	preload("res://random_book/book_cover3.png"),
]
const PAPER = preload("res://random_book/paper.png")
const BOW = [
	preload("res://random_book/bow.png"),
	preload("res://random_book/bow2.png"),
	preload("res://random_book/bow3.png"),
]
const TEXTS = [
	preload("res://random_book/text1.png"),
	preload("res://random_book/text2.png"),
	preload("res://random_book/text3.png"),
	preload("res://random_book/text4.png"),
]

var book_image:Image


func _ready():
	_debug_get_used_colors( PAPER.get_data() )


func generate_book() -> Image:
	book_image = Image.new()
	
	book_image.create(16, 16, false, Image.FORMAT_RGBA8)
	
	#
	var cover:Image = COVER[randi()%COVER.size()].get_data()
	_draw_layer(16, cover, book_image, 3.0)
	
	#
	var paper:Image = PAPER.get_data()
	_draw_layer(16, paper, book_image, 1.0,
		Color.white,
		Color.white,
		Color.white
	)
		
	#
	if randi()%100 > 33:
		var text:Image = TEXTS[randi()%TEXTS.size()].get_data()
		_draw_layer(16, text, book_image, 1.0,
			Color(0.1, 0.1, 0.1, 0.3),
			Color(0.1, 0.1, 0.1, 0.3),
			Color(0.1, 0.1, 0.1, 0.3)
		)
	
	#
	if randi()%100 > 33:
		var bow:Image = BOW[randi()%BOW.size()].get_data()
		_draw_layer(16, bow, book_image, 1.0)
	
	return book_image

const CRS = 0.7
const CRE = 0.98
func _draw_layer(res:int, from_image:Image, to_image:Image, lightness:float = 1.0, tint_color1:Color = Color.black, tint_color2:Color = Color.black, tint_color3:Color = Color.black):
	if tint_color1 == Color.black:
		tint_color1 = rand_color()
		
	if tint_color2 == Color.black:
		tint_color2 = rand_color()
		
	if tint_color3 == Color.black:
		tint_color3 = rand_color()
	
	for x in res:
		for y in res:
			from_image.lock()
			var col:Color = from_image.get_pixel(x,y)
			from_image.unlock()
			
			if col.a == 0: # Skip to visible pixel...
				continue
			
			col *= lightness
			
			if col.r > 0.0: # Uses Tint1
				if tint_color1.a >= 1.0:
					col = Color(col.r,col.r,col.r) * tint_color1
				else:
					col = Color(col.r,col.r,col.r).linear_interpolate(Color(col.r,col.r,col.r) * tint_color1, tint_color1.a)
			
			elif col.g > 0.0: # Uses Tint2
				if tint_color2.a >= 1.0:
					col = Color(col.g,col.g,col.g) * tint_color2
				else:
					col = Color(col.g,col.g,col.g).linear_interpolate(Color(col.g,col.g,col.g) * tint_color2, tint_color2.a)
			
			elif col.b > 0.0: # Uses Tint3
				if tint_color3.a >= 1.0:
					col = Color(col.b,col.b,col.b) * tint_color3
				else:
					col = Color(col.b,col.b,col.b).linear_interpolate(Color(col.b,col.b,col.b) * tint_color3, tint_color3.a)
			
			else: # Just black
				col = Color.black
			
			# Lazy fix
			col.a = 1.0
			
			to_image.lock()
			to_image.set_pixel(x,y,col)
			to_image.unlock()



func _debug_get_used_colors(image:Image):
	var used_colors = []
	for x in image.data.width:
		for y in image.data.height:
			image.lock()
			var col:Color = image.get_pixel(x,y)
			if !used_colors.has(col):
				used_colors.append(col)
			image.unlock()


func rand_color() -> Color:
	return COLOR_COLORS[randi() % COLOR_COLORS.size()].contrasted()
