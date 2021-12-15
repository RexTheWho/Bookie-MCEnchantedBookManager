extends Control


# ResPack/assets/minecraft
#	Model:		../models/item/[ItemJSON]
#	Properties:	../optifine/cit/enchantments/[Properties]
#	Sprite:		../textures/item/[SpritePNG]


onready var resource_pack_path = OS.get_executable_path().left(OS.get_executable_path().find_last("/"))
const PATH_MODEL = "assets/minecraft/models/item"
const PATH_PROPERTIES = "assets/minecraft/optifine/cit/enchantments"
const PATH_TEXTURE = "assets/minecraft/textures/item"


const MODELTEMPLATE = {
  "parent": "item/generated",
  "textures": {
	"layer0": "minecraft:item/{enchantment_and_level}"
  }
}
const PROPTEMP_type =		"type=item"
const PROPTEMP_item =		"items=enchanted_book"
const PROPTEMP_texture =	"texture=assets/minecraft/textures/item/%s.png"
const PROPTEMP_enchant =	"enchantmentIDs=%s"
const PROPTEMP_level =		"enchantmentLevels=%s"


export(NodePath) var mod_id
export(NodePath) var book_button
export(NodePath) var step_by_step_label
export(NodePath) var warning_label


var book_id:String = "testingness"
var book_level:int = 0
var book_image:Image


func _ready():
	prints("OUTPUTTING TO:", resource_pack_path)
	get_node(warning_label).text = "!! OUTPUT WARNING !!\n" + resource_pack_path + ".."
	OS.center_window()
	OS.set_window_title("Bookie")
	get_tree().connect("files_dropped", self, "_files_dropped") # warning-ignore:return_value_discarded


func _files_dropped(files:PoolStringArray, _screen:int):
	var path:String = files[0]
	if path.get_extension() == "png":
		get_node(step_by_step_label).text = "Now press the book to output!"
		set_bookbutton_sprite(path)
		var sprite = path.right(path.find_last("\\")+1).trim_suffix(".png")
		book_id = ""
		
		# Has enchant level...
		# Will not work with double digits! (I dont really expect many people to go over 9 anyway...)
		book_level = 0
		for l in sprite:
			var num = int(l)
			if num > 0:
				book_level = num
			else:
				book_id += l
		print(get_enchantment_and_mod())
	
	# not valid sprite...
	else:
		push_warning("Failed to build book, this is not a PNG file!")


func set_bookbutton_sprite(path:String):
	book_image = Image.new()
	if book_image.load(path) != OK:
		book_image.lock()
		book_image.fill(Color.purple)
		book_image.unlock()
		push_warning("Image could not be loaded, Enjoy purple!")
	
	var book_texture:ImageTexture = ImageTexture.new()
	book_texture.create_from_image(book_image,0)
	var texbutt = get_node(book_button)
	texbutt.texture_normal = book_texture
	texbutt.texture_pressed = book_texture
	texbutt.texture_hover = book_texture
	texbutt.texture_focused = book_texture
	texbutt.self_modulate = Color.white
	texbutt.disabled = false


func _on_bookbutton_pressed():
#	Model might only be vanilla thing... oops
#	save_book_model()
	save_book_property()
	save_book_texture()


func save_book_model():
	print("Saving Model!")
	
	check_and_correct_directory(get_output_model())
	var save_path = "%s/%s%s"%[get_output_model(), get_enchantment_and_level(), ".json"]
	
	var item_dict:Dictionary = MODELTEMPLATE.duplicate()
	item_dict.textures.layer0 = get_enchantment_and_level()
	var file:File = File.new()
	var json_string = JSON.print(item_dict, "\t")
	print(json_string)
	#Save it
	if file.open(save_path, File.WRITE) == OK:
		file.store_string(json_string)
		file.close()
		print("Saved Model!")
	else:
		push_warning("Failed to save Model!")


func save_book_property():
	print("Saving Property!")
	$AudioStreamPlayer.play(0.0)
	check_and_correct_directory(get_output_properties())
	var save_path = "%s/%s%s"%[get_output_properties(), get_enchantment_and_level(), ".properties"]
	var file:File = File.new()
	var stuff:String = ""
	stuff += PROPTEMP_type + "\n"
	stuff += PROPTEMP_item + "\n"
	stuff += PROPTEMP_texture % get_enchantment_and_level() + "\n"
	stuff += PROPTEMP_enchant % get_enchantment_and_mod() + "\n"
	if book_level > 0:
		stuff += PROPTEMP_level % book_level + "\n"
	
	#Save it
	if file.open(save_path, File.WRITE) == OK:
		file.store_string(stuff)
		file.close()
		print("Saved Property!")
	else:
		push_warning("Failed to save Property!")


func save_book_texture():
	print("Saving Texture!")
	check_and_correct_directory(get_output_texture())
	var save_path = "%s/%s%s"%[get_output_texture(), get_enchantment_and_level(), ".png"]
	if book_image.save_png(save_path) != OK:
		push_warning("Failed to save Texture!")


func get_enchantment_and_level() -> String:
	var string = book_id
	if book_level > 0: string += str(book_level)
	return string


func get_enchantment_and_mod() -> String:
	var string = book_id
	var mod_name = get_node(mod_id).text
	if mod_name != "":
		string = mod_name + ":" + string
	return string


func get_mod_id() -> String:
	var modid = get_node(mod_id)
	return modid.text


func get_output_model() -> String:
	return resource_pack_path + "/" + PATH_MODEL


func get_output_properties() -> String:
	return resource_pack_path + "/" + PATH_PROPERTIES


func get_output_texture() -> String:
	return resource_pack_path + "/" + PATH_TEXTURE


func check_and_correct_directory(path):
	var dir:Directory = Directory.new()
	dir.make_dir_recursive(path)
