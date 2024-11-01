extends Control

@onready var inv: Inventory = preload("res://entities/Player/inventory/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open: bool = false

func _ready():
	inv.update.connect(update_slots)
	inv.spawn.connect(spawn_item)
	connect_slots()
	update_slots()
	close()

func spawn_item(item: InventoryItem):
	var scene: PackedScene = load("res://entities/Player/inventory/items/"+ item.name +".tscn")
	var object = scene.instantiate()
	var spr: Sprite2D = object.get_node("Sprite2D")
	object.item = item
	spr.texture = item.texture
	if inv.player != null:
		object.position = inv.player.global_position
	get_tree().root.get_child(0).add_child(object)


func connect_slots():
	for i in range(slots.size()):
		slots[i].drop.connect(_drop_item)
		slots[i].drop_all.connect(_drop_items)
		slots[i].use.connect(_use_item)
		
func _drop_item(inv_item: InventoryItem):
	inv.drop(inv_item)
	
func _drop_items(inv_item: InventoryItem):
	inv.drop_all(inv_item)

func _use_item(inv_item: InventoryItem):
	inv.use(inv_item, inv_item.one_time)
	inv_item.action.call("select", inv.player)

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()
	if Input.is_action_just_pressed("escape"):
		close()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])


func close():
	visible = false;
	is_open = false;
	if is_instance_valid(inv.player) and  inv.player: inv.player.unpause()
	
	
func open():
	visible = true
	is_open = true
	if is_instance_valid(inv.player) and inv.player : inv.player.pause()
