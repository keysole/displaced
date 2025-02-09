extends "res://files/Close Panel Button/ClosingPanel.gd"

onready var charlist = $Panel/ScrollContainer/HBoxContainer
onready var w1panel = $Panel/weapon1
onready var w2panel = $Panel/weapon2
onready var armpanel = $Panel/armor


var selected_char
var selected_slot = null


export var test_mode = false

func _ready():
	visible = false
	if resources.is_busy(): 
		yield(resources, "done_work")
	input_handler.ClearContainer(charlist, ['panel'])
	for cid in state.characters:
		var hero = state.heroes[cid]
		var ch = input_handler.DuplicateContainerTemplate(charlist, 'panel')
		ch.name = cid
		ch.get_node('Label').text = hero.name
		ch.get_node('TextureRect').texture = hero.portrait()
		ch.connect('pressed', self, 'select_hero', [cid])
	
	if test_mode:
		testmode()
		if resources.is_busy(): 
			yield(resources, "done_work")
		open()

func testmode():
	for cid in state.characters:
		state.unlock_char(cid)
#	state.unlock_char('rose', false)


func RepositionCloseButton():
	var rect = $Panel.get_global_rect()
	var pos = Vector2(rect.end.x + 6 - closebutton.rect_size.x - closebuttonoffset[0], rect.position.y + closebuttonoffset[1])
	closebutton.set_global_position(pos)


func open():
	TutorialCore.check_event('village_craft_open')
	$Tooltip.hide()
	for cid in state.characters:
		var ch = charlist.get_node(cid)
		ch.visible = (state.heroes[cid].unlocked)
	select_hero('arron')
#	input_handler.UnfadeAnimation(self)
	show()


func select_hero(cid):
	if !TutorialCore.check_action("craft_hero_selected", [cid]): return
	for ch in charlist.get_children():
		ch.pressed = (ch.name == cid)
		ch.rebuild()
	if cid == selected_char: return
	selected_char = cid
	selected_slot = null
	rebuild_gear(cid)
	slot_select()
	


func rebuild_gear(cid = selected_char):
	var hero = state.heroes[cid]
	rebuild_gear_slot(w1panel, hero.get_item_data('weapon1'), hero.get_item_upgrade_data('weapon1'))
	rebuild_gear_slot(w2panel, hero.get_item_data('weapon2'), hero.get_item_upgrade_data('weapon2'))
	rebuild_gear_slot(armpanel, hero.get_item_data('armor'), hero.get_item_upgrade_data('armor'))
	highlight_slot()


func rebuild_gear_slot(node, data, newdata):
	node.connect('pressed', self, 'slot_select', [data.type])
	node.get_node("Icon").texture = data.icon
	node.get_node("Label2").text = data.name
	if data.level > 0:
		node.get_node("Label").text = "Level %d" % data.level
	else:
		node.get_node("Label").text = ""
	if newdata != null:
		node.get_node("Button").visible = true
		node.get_node("Button").disabled = false
		node.get_node("VBoxContainer").visible = true
		node.get_node("ResPanel").visible = true
		input_handler.ClearContainer(node.get_node("VBoxContainer"), ['button'])
		for res in newdata.cost:
			if res == 'gold': continue
			var panel = input_handler.DuplicateContainerTemplate(node.get_node("VBoxContainer"), 'button')
			panel.get_node('icon').texture = Items.Items[res].icon #as it is now - items icons are loaded directly on start
			panel.get_node("Label").text = "%d/%d" % [newdata.cost[res], state.materials[res]]
			if newdata.cost[res] > state.materials[res]:
				node.get_node("Button").disabled = true
				panel.get_node("Label").set("custom_colors/font_color", variables.hexcolordict.red)
		node.get_node("Button").connect("pressed", self, 'upgrade_slot', [data.type])
	else:
		node.get_node("Button").visible = false
		node.get_node("VBoxContainer").visible = false
		node.get_node("ResPanel").visible = false


func upgrade_slot(slot):
	if !TutorialCore.check_action("craft_slot_upg", [slot]): return
	var hero = state.heroes[selected_char]
	var cost = hero.get_item_upgrade_data(slot).cost
	hero.upgrade_gear(slot)
	for res in cost:
		if res == 'gold':
			state.money -= cost[res]
		else:
			state.materials[res] -= cost[res]
	rebuild_gear()
	TutorialCore.check_event('craft_slot_upg')


func slot_select(slot = selected_slot):
	if slot == selected_slot:
		selected_slot = null
		$Tooltip.hide()
	else:
		selected_slot = slot
		$Tooltip.build_slot_tooltip(selected_char, selected_slot)
		$Tooltip.show()
	highlight_slot()

func highlight_slot():
	for sid in ['weapon1', 'weapon2', 'armor']:
		var node = $Panel.get_node(sid)
		if sid == selected_slot:
			node.pressed = true
			node.get_node("Label").set("custom_colors/font_color", variables.hexcolordict.highlight_blue)
			node.get_node("Label2").set("custom_colors/font_color", variables.hexcolordict.highlight_blue)
			for nd in node.get_node('VBoxContainer').get_children():
				var lb = nd.get_node('Label')
				if lb.get("custom_colors/font_color") != Color(variables.hexcolordict.red):
					lb.set("custom_colors/font_color", variables.hexcolordict.highlight_blue)
		else:
			node.pressed = false
			node.get_node("Label").set("custom_colors/font_color", variables.hexcolordict.light_grey)
			node.get_node("Label2").set("custom_colors/font_color", variables.hexcolordict.light_grey)
			for nd in node.get_node('VBoxContainer').get_children():
				var lb = nd.get_node('Label')
				if lb.get("custom_colors/font_color") != Color(variables.hexcolordict.red):
					lb.set("custom_colors/font_color", variables.hexcolordict.light_grey)
