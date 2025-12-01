extends Control
signal next_turn_button_pressed

@export var text : Label

@onready var damage_rect : ColorRect = get_node("%DamageRect")
@onready var button_rect : ColorRect = get_node("%ButtonRect")

func change_text(new_text: String):
	get_node("ReferenceRect/Label").text = new_text

func _on_button_pressed():
	next_turn_button_pressed.emit()

func animate_damage():
	damage_rect.show()
	damage_rect.get_node("DamageAnimation").play("damage_animation")
	await get_tree().create_timer(0.5).timeout
	damage_rect.hide()

func animate_water_splash():
	damage_rect.show()
	damage_rect.get_node("DamageAnimation").play("water_animation")
	await get_tree().create_timer(0.5).timeout
	damage_rect.hide()

func next_turn_screen():
	button_rect.get_node("ButtonAnimation").play("next_turn_animation")
	button_rect.show()
	await next_turn_button_pressed
	button_rect.get_node("ButtonAnimation").play("stopped")
	button_rect.hide()
