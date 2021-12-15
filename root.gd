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
export(NodePath) var enchant_id
export(NodePath) var book_button
export(NodePath) var step_by_step_label
export(NodePath) var warning_label


var book_id:String = "default_name"
var book_level:int = 0
onready var book_image:Image = Image.new()


func _ready():
	randomize()
	prints("OUTPUTTING TO:", resource_pack_path)
	get_node(warning_label).text = "!! OUTPUT WARNING !!\n" + resource_pack_path + ".."
	OS.center_window()
	if randi()%100 == 0:
		OS.set_window_title("Bowokie")
	else:
		OS.set_window_title("Bookie")
	get_tree().connect("files_dropped", self, "_files_dropped") # warning-ignore:return_value_discarded
	book_image.load("res://default.png")


func _files_dropped(files:PoolStringArray, _screen:int):
	var path:String = files[0]
	if path.get_extension() == "png":
		set_bookbutton_sprite_from_path(path)
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
	
	# not valid sprite...
	else:
		push_warning("Failed to build book, this is not a PNG file!")


func set_bookbutton_sprite_from_path(path:String):
	book_image = Image.new()
	if book_image.load(path) != OK:
		book_image.lock()
		book_image.fill(Color.purple)
		book_image.unlock()
		push_warning("Image could not be loaded, Enjoy purple!")
	_enable_bookbutton()


func set_bookbutton_sprite_from_image(image:Image):
	book_image = image
	_enable_bookbutton()


func _enable_bookbutton():
	var texbutt = get_node(book_button)
	
	var book_texture:ImageTexture = ImageTexture.new()
	if book_image:
		book_texture.create_from_image(book_image,0)
		texbutt.texture_normal = book_texture
		texbutt.texture_pressed = book_texture
		texbutt.texture_hover = book_texture
		texbutt.texture_focused = book_texture
		
	texbutt.self_modulate = Color.white
	texbutt.disabled = false
	get_node(step_by_step_label).text = "Now press the book to output!"


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
	stuff += PROPTEMP_texture % get_enchant_texture_id() + "\n"
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
	var save_path = "%s/%s%s"%[get_output_texture(), get_enchant_texture_id(), ".png"]
	if book_image == null:
		book_image = Image.new()
		book_image.load("res://error.png")
	if book_image.save_png(save_path) != OK:
		push_warning("Failed to save Texture!")


func get_enchantment_and_level() -> String:
	var string = get_book_id()
	if book_level > 0: string += str(book_level)
	return string


func get_enchantment_and_mod() -> String:
	var string = get_book_id()
	var mod_name = get_node(mod_id).text
	if mod_name != "":
		string = mod_name + ":" + string
	return string


func get_enchant_texture_id() -> String:
	var string = get_book_id()
	var mod_name = get_node(mod_id).text
	if mod_name != "":
		string = mod_name + "_" + string
	if book_level > 0:
		string += str(book_level)
	return string


func get_mod_id() -> String:
	var modid = get_node(mod_id)
	return modid.text


func get_book_id() -> String:
	var book_it_return = book_id
	var enchant_ovr = get_node(enchant_id)
	if enchant_ovr.text != "":
		book_it_return = enchant_ovr.text
	return book_it_return


func get_output_model() -> String:
	return resource_pack_path + "/" + PATH_MODEL


func get_output_properties() -> String:
	return resource_pack_path + "/" + PATH_PROPERTIES


func get_output_texture() -> String:
	return resource_pack_path + "/" + PATH_TEXTURE


func check_and_correct_directory(path):
	var dir:Directory = Directory.new()
	dir.make_dir_recursive(path) # warning-ignore:return_value_discarded


func _on_random_book_pressed():
	var book = $RandomBookGenerator.generate_book()
	set_bookbutton_sprite_from_image(book)


# Can change this later, small UI stuff
var _on_EnchantmentOverride_text_entered_once = true
func _on_EnchantmentOverride_text_entered_once(_t):
	if _on_EnchantmentOverride_text_entered_once == true:
		print("_on_EnchantmentOverride_text_entered_once")
		_on_EnchantmentOverride_text_entered_once = false
		_enable_bookbutton()


func _on_lockontop_toggled(button_pressed):
	OS.set_window_always_on_top(button_pressed)
	if button_pressed:
		$Tween.interpolate_property($Locked, "self_modulate:a", $Locked.self_modulate.a, 1.0, 0.1)
	else:
		$Tween.interpolate_property($Locked, "self_modulate:a", $Locked.self_modulate.a, 0.0, 0.1)
	$Tween.start()
