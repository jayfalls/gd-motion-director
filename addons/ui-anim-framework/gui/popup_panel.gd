@tool
class_name UIAnimationPopupPanel extends PopupPanel


signal le_confirmed(value)
signal yn_confirmed


# VARIABLES
## Constants
const popup_types: PackedStringArray = [
	"line_edit_popup",
	"yes_no_popup"
]
## Line Edit Popup
@onready var line_edit_popup: MarginContainer = $LineEditPopup
### Children
@onready var le_description: Label = $LineEditPopup/VBoxContainer/PopupDescriptionLabel
@onready var le_warning_label: Label = $LineEditPopup/VBoxContainer/WarningLabel
@onready var le_line_edit: LineEdit = $LineEditPopup/VBoxContainer/LineEdit
@onready var le_cancel_button: Button = $LineEditPopup/VBoxContainer/HBoxContainer/CancelButton
@onready var le_confirm_button: Button = $LineEditPopup/VBoxContainer/HBoxContainer/ConfirmButton
### Values
var invalid_texts: PackedStringArray = []:
	set(value):
		invalid_texts.clear()
		for text in value:
			invalid_texts.append(text.to_upper())

## Yes No Popup
@onready var yes_no_popup: MarginContainer = $YesNoPopup
### Children
@onready var yn_description: Label = $YesNoPopup/VBoxContainer/PopupDescriptionLabel
@onready var yn_yes_button: Button = $YesNoPopup/VBoxContainer/HBoxContainer/YesButton
@onready var yn_no_button: Button = $YesNoPopup/VBoxContainer/HBoxContainer/NoButton


# SHOW/HIDE POPUPS
func _toggle_popups(index: int) -> void:
	line_edit_popup.hide()
	yes_no_popup.hide()
	self[popup_types[index]].show()

func line_edit_popup_show(descrip: String) -> void:
	_toggle_popups(0)
	le_description.text = descrip
	_test_le_popup()
	le_line_edit.text = ""
	popup()
	le_line_edit.grab_focus()

func yes_no_popup_show(descrip: String) -> void:
	_toggle_popups(1)
	yn_description.text = descrip
	popup()


# LINE EDIT POPUP
## Validity Check
func _set_le_warning(text: String) -> void:
	if text == "":
		le_confirm_button.disabled = false
		le_warning_label.add_theme_color_override("font_color",Color.GREEN)
		le_warning_label.text = "Valid"
	else:
		le_confirm_button.disabled = true
		le_warning_label.add_theme_color_override("font_color",Color.ORANGE)
		le_warning_label.text = text

func _test_le_popup() -> void:
	if le_line_edit.text == "":
		_set_le_warning("Needs a name")
	elif le_line_edit.text.to_upper() in invalid_texts:
		_set_le_warning("'" + le_line_edit.text + "' already exists")
	else:
		_set_le_warning("")


## Input Updates
func _on_line_edit_text_changed(new_text):
	_test_le_popup()

func _on_cancel_button_pressed():
	hide()

func _on_confirm_button_pressed():
	le_confirmed.emit(le_line_edit.text)
	hide()


# YES NO POPUP
## Input Updates
func _on_yes_button_pressed():
	yn_confirmed.emit()
	hide()

func _on_no_button_pressed():
	hide()
