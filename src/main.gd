extends PanelContainer

# FIXME sleep 1 is ok with manual button run
# but crashes with Ctrl+Enter

const TMP_SCRIPT_PATH := "user://tmp_script"
const USR_SHEBANG := "#!/usr/bin/env "

# var _input_history: Array[String]


func _input(event: InputEvent) -> void:
	if event.is_action("quit"):
		request_quit()
		accept_event()
	elif event.is_action("paste"):
		# fix Godot Ctrl+Shift
		if Input.is_key_pressed(KEY_SHIFT):
			paste_from_clipboard()
			accept_event()
	elif event.is_action("run"):
		if Input.is_key_pressed(KEY_CTRL):
			run()
			accept_event()


func _create_tmp_script(content: String) -> void:
	var f := FileAccess.open(TMP_SCRIPT_PATH,
			FileAccess.WRITE)
	f.store_string(USR_SHEBANG + %ShellTxt.text + "\n")
	f.store_string(content)


# func _register_history(command: String) -> void:
# 	_input_history += command


func append_console(text: String) -> void:
	# %Console.text += text
	%Console.append_text(text)


func paste_from_clipboard() -> void:
	%Input.text = DisplayServer.clipboard_get()


func run() -> void:
	var input = %Input.text
	# TODO test sleep 1
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
