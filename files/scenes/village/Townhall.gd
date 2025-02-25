extends "res://files/Close Panel Button/ClosingPanel.gd"

var selectedworker
var selectedupgrade

var binded_events = {}
onready var charpanel = $UpcomingEvents/ScrollContainer/HBoxContainer

func _ready():
	input_handler.connect("EventFinished", self, "build_events")
	#$ButtonPanel/VBoxContainer/Tasks.connect("pressed",self,'tasklist')
#warning-ignore:return_value_discarded
	$ButtonPanel/VBoxContainer/Upgrades.connect('pressed', self, 'upgradelist')
#warning-ignore:return_value_discarded
	$UpgradeDescript/UnlockButton.connect("pressed", self, 'unlockupgrade')
#warning-ignore:return_value_discarded
#	$ButtonPanel/VBoxContainer/Food.connect('pressed', $FoodConvert, "open")
#warning-ignore:return_value_discarded
	$ButtonPanel/VBoxContainer/Quests.connect("pressed", $Questlog, 'open')
	$ButtonPanel/VBoxContainer/Scenes.connect("pressed", $scenes, "open")
	#globals.AddPanelOpenCloseAnimation($TaskList)
	globals.AddPanelOpenCloseAnimation($UpgradeList)
	globals.AddPanelOpenCloseAnimation($UpgradeDescript)
	
	binded_events.clear()
#	visible = false
#	if resources.is_busy(): yield(resources, "done_work")
#	open()


func open():
	TutorialCore.check_event("village_townhall_open")
	$UpgradeList.hide()
	$UpgradeDescript.hide()
	show()

func show():
	state.CurBuild = 'TownHall';
#	globals.check_signal("BuildingEntered", 'TownHall')
	.show();

func hide():
	if !TutorialCore.check_action("village_townhall_hide"): return
	state.CurBuild = "";
	.hide();

#func selecttaskfromlist(task):
#	$SelectWorker.OpenSelectTab(task)

func upgradelist():
	$UpgradeList.show()
	$UpgradeDescript.hide()
	input_handler.ClearContainer($UpgradeList/ScrollContainer/VBoxContainer)
	var array = []
	for i in Upgradedata.upgradelist.values():
		array.append(i)
	
	array.sort_custom(self, 'sortupgrades')
	
	for i in array:
		var currentupgradelevel = findupgradelevel(i)
	
		var check = true
		if i.levels.has(currentupgradelevel):
			for k in i.levels[currentupgradelevel].unlockreqs:
				if state.valuecheck(k) == false:
					check = false
		if check == false:
			continue
	
		var text = tr(i.name)
	
		if currentupgradelevel > 1 && i.levels.has(currentupgradelevel):
			text += ": " + str(currentupgradelevel)
	
		var newbutton = input_handler.DuplicateContainerTemplate($UpgradeList/ScrollContainer/VBoxContainer)
		if i.levels.has(currentupgradelevel) == false:
			newbutton.get_node("name").set("custom_colors/font_color", Color(0,0.6,0))
			text += ' Unlocked'
			newbutton.get_node("icon").texture = i.levels[currentupgradelevel-1].icon
		else:
			newbutton.get_node("icon").texture = i.levels[currentupgradelevel].icon
		newbutton.get_node("name").text = text
		newbutton.connect("pressed", self, "selectupgrade", [i])


func sortupgrades(first, second):
	if first.levels.has(findupgradelevel(first)) && second.levels.has(findupgradelevel(second)):
		if first.positionorder < second.positionorder:
			return true
		else:
			return false
	elif first.levels.has(findupgradelevel(first)):
		return true
	else:
		return false


func selectupgrade(upgrade):
	var text = tr(upgrade.descript)
	selectedupgrade = upgrade
	$UpgradeDescript.show()
	$UpgradeDescript/Label.text = upgrade.name
	
	input_handler.ClearContainer($UpgradeDescript/HBoxContainer)
	
	var currentupgradelevel = findupgradelevel(upgrade)
	
	if currentupgradelevel > 1:
			text += '\n\n' + tr("UPGRADEPREVBONUS") + ': ' + tr(upgrade.levels[currentupgradelevel-1].bonusdescript)
	
	var canpurchase = true
	
	if upgrade.levels.has(currentupgradelevel):
		text += '\n\n' + tr("UPGRADENEXTBONUS") + ': ' + tr(upgrade.levels[currentupgradelevel].bonusdescript)
	
		for i in upgrade.levels[currentupgradelevel].cost:
			if i != 'gold':
				var item = Items.Items[i]
				var newnode = input_handler.DuplicateContainerTemplate($UpgradeDescript/HBoxContainer)
				newnode.get_node("icon").texture = item.icon
				newnode.get_node("Label").text = str(state.materials[i]) + "/"+ str(upgrade.levels[currentupgradelevel].cost[i])
				globals.connectmaterialtooltip(newnode, item)
				if state.materials[i] >= upgrade.levels[currentupgradelevel].cost[i]:
					newnode.get_node('Label').set("custom_colors/font_color", Color(0,0.6,0))
				else:
					newnode.get_node('Label').set("custom_colors/font_color", Color(0.6,0,0))
					canpurchase = false
			else:
				var newnode = input_handler.DuplicateContainerTemplate($UpgradeDescript/HBoxContainer)
				newnode.get_node("icon").texture = load("res://assets/images/iconsitems/gold.png")
				newnode.get_node("Label").text = str(state.money) + "/"+ str(upgrade.levels[currentupgradelevel].cost[i])
				if state.money >= upgrade.levels[currentupgradelevel].cost[i]:
					newnode.get_node('Label').set("custom_colors/font_color", Color(0,0.6,0))
				else:
					newnode.get_node('Label').set("custom_colors/font_color", Color(0.6,0,0))
					canpurchase = false
	else:
		canpurchase = false

	$UpgradeDescript/RichTextLabel.bbcode_text = text
	$UpgradeDescript/UnlockButton.visible = canpurchase


func findupgradelevel(upgrade):
	var rval = 1
	if state.townupgrades.has(upgrade.code):
		rval += state.townupgrades[upgrade.code]
	return rval


func unlockupgrade():
	if !TutorialCore.check_action("village_upgrade_purchase", [selectedupgrade.code]): return
	var upgrade = selectedupgrade
	var currentupgradelevel = findupgradelevel(upgrade)
	for i in upgrade.levels[currentupgradelevel].cost:
		if i == 'gold':
			state.money -= upgrade.levels[currentupgradelevel].cost[i]
		else:
			state.materials[i] -= upgrade.levels[currentupgradelevel].cost[i]
	
	if state.townupgrades.has(upgrade.code):
		state.townupgrades[upgrade.code] += 1
	else:
		state.townupgrades[upgrade.code] = 1
	
	input_handler.SystemMessage(tr("UPGRADEUNLOCKED") + ": " + upgrade.name)
	upgradelist()
	#animation
	if upgrade.levels[currentupgradelevel].has("townnode"):
		var animnode
		if get_parent().has_node(upgrade.levels[currentupgradelevel].townnode):
			animnode = get_parent().get_node(upgrade.levels[currentupgradelevel].townnode)
		else:
			animnode = get_parent().get_node("Background/"+upgrade.levels[currentupgradelevel].townnode)
		if animnode != null:
			self.modulate.a = 0
			animnode.show()
			input_handler.ShowOutline(animnode)
			input_handler.UnfadeAnimation(animnode, 2.5, 0)
			input_handler.PlaySound("building")
			yield(get_tree().create_timer(2.5), 'timeout')
			self.modulate.a = 1
			input_handler.HideOutline(animnode)
	TutorialCore.check_event("village_upgrade_purchase", selectedupgrade.code)
#	globals.check_signal("UpgradeUnlocked", upgrade)
#	globals.EventCheck()
	#state.townupgrades[upgrade.code] = true


func build_events():
	var res = false
	binded_events.clear()
	for ch in Explorationdata.characters:
		for seq in Explorationdata.characters[ch]:
			if state.check_sequence(seq):
				binded_events[ch] = seq
				res = true
				break
	
	$UpcomingEvents.visible = false
	input_handler.ClearContainer(charpanel, ['portrait'])
	for ch in binded_events:
		if binded_events[ch] == null: continue
		$UpcomingEvents.visible = true
		var panel = input_handler.DuplicateContainerTemplate(charpanel, 'portrait')
		panel.connect("pressed", self, "run_seq", [ch])
		var tex = resources.get_res("portrait/%s" % input_handler.scene_node.char_map[ch].portrait)
		panel.texture_normal = tex
	
	return res


func run_seq(ch):
	if !TutorialCore.check_action("village_run_seq", [ch]): return
	globals.run_seq(binded_events[ch])
