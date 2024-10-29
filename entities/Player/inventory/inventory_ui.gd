extends Control

@onready var inv: Inventory = preload("res://entities/Player/inventory/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()


var is_open: bool = false

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])


func close():
	visible = false;
	is_open = false;
	
	
func open():
	visible = true
	is_open = true
