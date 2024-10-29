extends Panel

@onready var item_display: Sprite2D = $CenterContainer/Panel/item
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(inv_slot: InventorySlot):
	if inv_slot.item:
		amount_text.visible = inv_slot.amount > 1;
		item_display.visible = true
		amount_text.text = str(inv_slot.amount)
		item_display.texture = inv_slot.item.texture;
	else:
		item_display.visible = false;
		amount_text.visible = false;
