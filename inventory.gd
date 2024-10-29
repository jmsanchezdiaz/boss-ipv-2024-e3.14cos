extends Resource
class_name Inventory

signal update


@export var slots : Array[InventorySlot]

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
	
	
func has(item_name: String):
	return !slots.filter(func(slot): return slot.item != null and item_name == slot.item.name).is_empty();
