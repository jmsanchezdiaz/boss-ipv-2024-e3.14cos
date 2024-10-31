extends Resource
class_name Inventory

signal update
signal spawn

@export var slots : Array[InventorySlot]

var player: Player;

func insert(item: InventoryItem):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	
	if item_slots.is_empty():
		var free_slots = slots.filter(func(slot): return slot.item == null)
		if !free_slots.is_empty():
			free_slots[0].item = item
			free_slots[0].amount = 1
	else:
		item_slots[0].amount += 1;
		
	update.emit()
	
func drop(item: InventoryItem):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	
	if item_slots[0].amount == 1:
		item_slots[0].item = null
		item_slots[0].amount = 0
	else:
		item_slots[0].amount -= 1
	spawn.emit(item)
	update.emit()
	
func use(item: InventoryItem, one_time: bool = true):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	
	if item_slots[0].amount == 1:
		item_slots[0].item = null if one_time else item_slots[0].item
		item_slots[0].amount = 0
	else:
		item_slots[0].amount -= 1
	
	update.emit()
	
func drop_all(item: InventoryItem):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	var current_amount = 0;
	if !item_slots.is_empty():
		item_slots[0].item = null;
		current_amount = item_slots[0].amount
		item_slots[0].amount = 0;
	
	for i in range(current_amount):
		spawn.emit(item)
	
	update.emit()
	
func has(item_name: String):
	return !slots.filter(func(slot): return slot.item != null and item_name == slot.item.name).is_empty();


func set_player(_player: Node2D):
	player= _player
