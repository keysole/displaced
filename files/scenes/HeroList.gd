extends Control

#var heropanel
#var equipopen = false


#func _process(delta):
#	for i in $HBoxContainer.get_children():
#		if i.name != "Button":
#			var hero = i.get_meta('hero')
#			i.get_node("hpbar").value = globals.calculatepercent(hero.hp, hero.hpmax)
#			i.get_node("mpbar").value = globals.calculatepercent(hero.mana, hero.manamax)
#	if heropanel.visible == false:
#		equipopen = false
#	if equipopen == false:
#		set_exclusive(false)
#		popup()
#		set_process(false)

func open():
	input_handler.ClearContainer($HBoxContainer)
	$HeroPanel.hide()
	show()
	#popup()
	for i in state.heroes.values():
		if !i.unlocked: continue
		var newbutton = input_handler.DuplicateContainerTemplate($HBoxContainer)
		newbutton.get_node("Label").text = i.name
		newbutton.get_node("Icon").texture = i.portrait()
#		newbutton.connect("pressed", self, "OpenEquip", [i])
		newbutton.connect("pressed", self, "OpenInfo", [i.id])
		newbutton.set_meta("hero", i)


#func OpenEquip(hero):
#	equipopen = true
#	$HeroPanel.open(hero)


func OpenInfo(ch_id):
	var node = input_handler.get_spec_node(input_handler.NODE_SLAVEPANEL)
	node.open(state.heroes[ch_id])
