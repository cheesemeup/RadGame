extends HBoxContainer

@export var slot_1  = self
@export var slot_2  = self
@export var slot_3  = self
@export var slot_4  = self
@export var slot_5  = self
@export var slot_6  = self
@export var slot_7  = self
@export var slot_8  = self
@export var slot_9  = self
@export var slot_10 = self
@export var slot_11 = self
@export var slot_12 = self


# triggering spells with action bar presses
func _on_actionbar_1_1_pressed():
	# return if no spell bound
	if slot_1 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_1.trigger()
