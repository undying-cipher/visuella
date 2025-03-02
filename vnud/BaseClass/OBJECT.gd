@tool
extends Area2D
class_name OBJECT

enum ObjectType { BASIC, CUSTOM, COLLECTIBLE, WORKINPROGRESS }

var object_manager: Node # todo: dependency injection 

var TYPE: ObjectType = ObjectType.BASIC

var sprites: Array[Sprite2D] 
var hover_effect: ShaderMaterial = null  

var basic_dialogue: String = ""
var collectible_id: String = ""  #or
var collectible_res: Resource = null
var work_in_progress_text: String = ""

var _last_type: int = -1
var sprite_node: Sprite2D = null

func _get_property_list():
	var properties: Array = []

	properties.append({
		"name": "TYPE",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "BASIC,CUSTOM,COLLECTIBLE,WORKINPROGRESS",
		"usage": PROPERTY_USAGE_DEFAULT
	})

	properties.append({
		"name": "sprites",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": str("%d/%d:" + "Sprite2D") % \
				[TYPE_OBJECT, PROPERTY_HINT_NODE_TYPE]
	})

	properties.append({
		"name": "hover_effect",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "ShaderMaterial",
		"usage": PROPERTY_USAGE_DEFAULT
	})

	if TYPE == ObjectType.BASIC:
		properties.append({
			"name": "basic_dialogue",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_MULTILINE_TEXT,
			"usage": PROPERTY_USAGE_EDITOR
		})

	if TYPE == ObjectType.COLLECTIBLE:
		properties.append({
			"name": "collectible_id",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_EDITOR
		})
	
	if TYPE == ObjectType.COLLECTIBLE:
		properties.append({
			"name": "collectible_res",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	if TYPE == ObjectType.WORKINPROGRESS:
		properties.append({
			"name": "work_in_progress_text",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_MULTILINE_TEXT,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return properties

func initialize():
	self.set_monitoring(false)
	update_group()

func _ready():
	if Engine.is_editor_hint():
		notify_property_list_changed() 
		find_sprite_node()
	else:
		initialize()


func _process(delta):
	if Engine.is_editor_hint():
		if _last_type != TYPE:
			_last_type = TYPE
			notify_property_list_changed()

func _set(property: StringName, value) -> bool:
	if property == "TYPE":
		TYPE = value
		notify_property_list_changed() 
		return true
	elif property == "collectible_res":
		collectible_res = value
		_update_sprite_texture()  
		return true
	
	return false
	
func find_sprite_node():
	if not sprite_node:
		for child in get_children():
			if child is Sprite2D:
				sprite_node = child
				break
				
func _update_sprite_texture():
	if Engine.is_editor_hint() and sprite_node and collectible_res and collectible_res.has("picture"):
		sprite_node.texture = collectible_res.picture

func update_group(group_name: String = "") -> void:
	for group in get_groups():
		remove_from_group(group)

	match TYPE:
		ObjectType.BASIC:
			add_to_group("BasicObjects")
		ObjectType.CUSTOM:
			add_to_group("CustomObjects")
		ObjectType.COLLECTIBLE:
			add_to_group("CollectibleObjects")
		ObjectType.WORKINPROGRESS:
			add_to_group("WorkInProgressObjects")

	if group_name:
		add_to_group(group_name)
		

func hovered():
	assert(hover_effect)
	for sprite in sprites:
		sprite.material = hover_effect

func unhovered():
	for sprite in sprites:
		sprite.material = null

func interact():
	match TYPE:
		ObjectType.BASIC:
			print("Basic dialogue: ", basic_dialogue)
		ObjectType.COLLECTIBLE:
			if object_manager:
				object_manager.collect(self.collectible_res) #no obj manager currently
			print("You collected: ", collectible_id)
			queue_free()
