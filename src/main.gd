extends PanelContainer

# FIXME sleep 1 is ok with manual button run
# but crashes with Ctrl+Enter

const TMP_SCRIPT_PATH := "user://tmp_script"
const SHEBANG := "#!/usr/bin/env "

# no const statically typed dictionary is GDScript
var INPUT_DIC := {
	&"abort": abort,
	&"empty": empty_console,
	&"paste": paste_from_clipboard,
	&"quit": request_quit,
	&"run": run,
}

# var _input_history: Array[String]


func _input(event: InputEvent) -> void:
	for action in INPUT_DIC:
		if event.is_action_pressed(action):
			print(action)
			INPUT_DIC[action].call()
			accept_event()


func _create_tmp_script(content: String) -> void:
	var f := FileAccess.open(TMP_SCRIPT_PATH,
			FileAccess.WRITE)

	if f == null:
		error("Cannot open " + TMP_SCRIPT_PATH
				+ " in write mode")
		return
	
	f.store_string(SHEBANG + %ShellTxt.text + "\n")
	f.store_string(content)


func abort() -> void:
	%PipedShell.abort()


func append_console(text: String) -> void:
	# %Console.text += text
	%Console.append_text(text)


func empty_console() -> void:
	print("empty console")
	%Console.text = ""


func error(msg: String) -> void:
	printerr(msg)
	var ed := %ErrorDialog
	ed.title = "Error"
	ed.dialog_text = msg
	ed.popup_centered()


func paste_from_clipboard() -> void:
	%Input.text = DisplayServer.clipboard_get()


func run() -> void:
	var input = %Input.text
#	_register_history(text)
	_create_tmp_script(input)
	var global_script_path := \
			ProjectSettings.globalize_path(TMP_SCRIPT_PATH)
	%PipedShell.run(global_script_path)

	if %EraseBtn.button_pressed:
		%Input.text = ""


func request_quit() -> void:
	print(get_stack()[0]["function"])
	get_tree().root.propagate_notification(
			NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
