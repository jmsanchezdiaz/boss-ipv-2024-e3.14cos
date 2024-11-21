extends Panel

@onready var item_display: Sprite2D = $CenterContainer/Panel/item
@onready var amount_text: Label = $CenterContainer/Panel/Label
@onready var actions_menu: MenuButton = $CenterContainer/Panel/MenuButton
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var slot: InventorySlot

signal drop
signal drop_all
signal use

enum OPTIONS {
	USE,
	DROP,
	DROP_ALL,
}

func _ready():
	actions_menu.get_popup().id_pressed.connect(_on_item_selected)
	actions_menu.get_popup().add_item("Usar", OPTIONS.USE)
	actions_menu.get_popup().add_item("Soltar", OPTIONS.DROP)
	actions_menu.get_popup().add_item("Soltar todos", OPTIONS.DROP_ALL)
	

func _on_item_selected(id: int):
	if !slot.item: return;
	audio.play()
	match id:
		OPTIONS.USE:
			use.emit(slot.item)
		OPTIONS.DROP:
			drop.emit(slot.item)
		OPTIONS.DROP_ALL:
			drop_all.emit(slot.item)
			
	

func update(inv_slot: InventorySlot):
	slot = inv_slot
	if inv_slot.item:
		if inv_slot.amount > 1:
			amount_text.visible = true;
			actions_menu.get_popup().set_item_disabled(OPTIONS.DROP_ALL, false)
		else:
			actions_menu.get_popup().set_item_disabled(OPTIONS.DROP_ALL, true)
		
		actions_menu.visible = true;
		item_display.visible = true
		amount_text.text = str(inv_slot.amount)
		item_display.texture = inv_slot.item.texture;
	else:
		actions_menu.visible = false;
		item_display.visible = false;
		amount_text.visible = false;


func _on_audio_stream_player_2d_finished():
	pass # Replace with function body.
