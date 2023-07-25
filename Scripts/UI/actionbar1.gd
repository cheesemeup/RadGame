extends HBoxContainer

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

# spell assignment
func assign_actionbar1_2():
	var imagepath = str("res://Assets/Spell_Icons/abyssalshell.png")
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	$actionbar1_2.icon = texture
func assign_actionbar1_3():
	var imagepath = str("res://Assets/Spell_Icons/abyssalshell.png")
	var image = Image.load_from_file(imagepath)
	var texture = ImageTexture.create_from_image(image)
	$actionbar1_3.icon = texture
	
# triggering spells with action bar presses
func _on_actionbar_1_2_pressed():
	# return if no spell bound
	if slot_2 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_2.trigger()
func _on_actionbar_1_3_pressed():
	# return if no spell bound
	if slot_3 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_3.trigger()
func _on_actionbar_1_4_pressed():
	# return if no spell bound
	if slot_4 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_4.trigger()
func _on_actionbar_1_5_pressed():
		# return if no spell bound
	if slot_5 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_5.trigger()
func _on_actionbar_1_6_pressed():
	# return if no spell bound
	if slot_6 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_6.trigger()
func _on_actionbar_1_7_pressed():
	# return if no spell bound
	if slot_7 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_7.trigger()
func _on_actionbar_1_8_pressed():
	# return if no spell bound
	if slot_8 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_8.trigger()
func _on_actionbar_1_9_pressed():
	# return if no spell bound
	if slot_9 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_9.trigger()
func _on_actionbar_1_10_pressed():
	# return if no spell bound
	if slot_10 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_10.trigger()
func _on_actionbar_1_11_pressed():
	# return if no spell bound
	if slot_11 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_11.trigger()
func _on_actionbar_1_12_pressed():
	# return if no spell bound
	if slot_12 == self:
		print("no spell bound")
		return
	# trigger spell scene
	slot_12.trigger()
