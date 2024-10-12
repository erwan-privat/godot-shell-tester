extends PanelContainer


const TMP_SCRIPT_PATH := "user://tmp_script"


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
		if Input.is_key_pressed(KEY_ENTER):
			run()
			accept_event()


func _create_tmp_script(content: String) -> void:
	var f := FileAccess.open(TMP_SCRIPT_PATH,
			FileAccess.WRITE)
	f.store_string(content)


# func append_console(text: String) -> void:
	# %Console.text += text


func paste_from_clipboard() -> void:
	%Input.text = DisplayServer.clipboard_get()


func run() -> void:
	_create_tmp_script(%Input.text)
	var global_script_path := ProjectSettings.globalize_path(
		TMP_SCRIPT_PATH)
	#%PipedShell.run(global_script_path, [], append_console)
	%PipedShell.run(global_script_path)
	%PipedShell.output.connect(%Console.append_text)


func request_quit() -> void:
	print(get_stack()[0]["function"])
	get_tree().root.propagate_notification(
			NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
