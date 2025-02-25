extends "res://files/Close Panel Button/ClosingPanel.gd"


var saveloadmode

func _ready():
#warning-ignore:return_value_discarded
	$LineEdit.connect("text_entered",self,'PressSaveGame')

func ResetSavePanel():
	match saveloadmode:
		'save':
			SavePanelOpen()
		'load':
			LoadPanelOpen()

func SavePanelOpen():
	show()
	saveloadmode = 'save'
	input_handler.ClearContainer($ScrollContainer/VBoxContainer)
	$LineEdit.editable = true
	for i in globals.dir_contents(globals.userfolder + 'saves'):
		if i.ends_with('.sav') == false:
			continue
		var newbutton = input_handler.DuplicateContainerTemplate($ScrollContainer/VBoxContainer)
		var savename = SaveNameTransform(i)
		newbutton.get_node("Delete").connect("pressed", self, 'DeleteSaveGame', [savename])
		newbutton.get_node("Label").text = savename
		newbutton.connect('pressed', self, 'PressSaveGame', [savename])

func LoadPanelOpen():
	show()
	saveloadmode = 'load'
	input_handler.ClearContainer($ScrollContainer/VBoxContainer)
	$LineEdit.editable = false
	$LineEdit.text = ''
	for i in globals.dir_contents(globals.userfolder + 'saves'):
		if i.ends_with('.sav') == false:
			continue
		var newbutton = input_handler.DuplicateContainerTemplate($ScrollContainer/VBoxContainer)
		var savename = SaveNameTransform(i)
		newbutton.get_node("Delete").connect("pressed", self, 'DeleteSaveGame', [savename])
		newbutton.get_node("Label").text = savename
		newbutton.connect('pressed', self, 'PressLoadGame', [savename])

func PressLoadGame(savename):
	$LineEdit.text = savename
	input_handler.get_spec_node(input_handler.NODE_CONFIRMPANEL, [self, 'LoadGame',tr("LOADCONFIRM")])#ShowConfirmPanel(self, 'LoadGame',tr("LOADCONFIRM"))

func PressSaveGame(savename):
	if savename == null:
		savename = $LineEdit.text
	else:
		$LineEdit.text = savename
	
	if savename == '':
		return
	
	var file = File.new()
	if file.file_exists(globals.userfolder + 'saves/' + savename + '.sav'):
		input_handler.get_spec_node(input_handler.NODE_CONFIRMPANEL, [self, 'SaveGame',tr("OVERWRITECONFIRM")])#ShowConfirmPanel(self, 'SaveGame',tr("OVERWRITECONFIRM"))
	else:
		SaveGame()

func DeleteSaveGame(savename):
	$LineEdit.text = savename
	input_handler.get_spec_node(input_handler.NODE_CONFIRMPANEL, [self, 'DeleteSave',tr("DELETECONFIRM")])#ShowConfirmPanel(self, 'DeleteSave',tr("DELETECONFIRM"))

func DeleteSave():
	var savename = $LineEdit.text
	var dir = Directory.new()
	dir.remove(globals.userfolder + 'saves/' + savename + '.sav')
	ResetSavePanel()

func SaveGame():
	globals.SaveGame($LineEdit.text)
	hide()
#	ResetSavePanel()

func LoadGame():
	globals.LoadGame($LineEdit.text)

func SaveNameTransform(path):
	return path.replace(globals.userfolder + 'saves/',"").replace('.sav', '')
