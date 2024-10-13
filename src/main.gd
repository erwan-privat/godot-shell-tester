extends PanelContainer

# FIXME sleep 1 is ok with manual button run
# but crashes with Ctrl+Enter

const TMP_SCRIPT_PATH := "user://tmp_script"
const SHEBANG := "#!/usr/bin/env "
const INPUT_DELAY_SEC := 0.1

# var _input_history: Array[String]
var _in_input_delay := false


func _process(_delta: float) -> void:
	if _in_input_delay:
		return

	if Input.is_action_pressed("quit"):
		request_quit()
	elif Input.is_action_pressed("paste"):
		# fix Godot Ctrl+Shift
		if Input.is_key_pressed(KEY_SHIFT):
			print("event paste")
			accept_event()
			paste_from_clipboard()
			delay_input()
	elif Input.is_action_pressed("run"):
		if Input.is_key_pressed(KEY_CTRL):
			print("event run")
			accept_event()
			run()
			delay_input()
	elif Input.is_action_pressed("empty"):
		print("event empty")
		accept_event()
		empty_console()
		delay_input()
	elif Input.is_action_pressed("abort"):
		print("event abort")
		accept_event()
		abort()
		delay_input()


func _create_tmp_script(content: String) -> void:
	var f := FileAccess.open(TMP_SCRIPT_PATH,
			FileAccess.WRITE)

	if f == null:
		error("Cannot open " + TMP_SCRIPT_PATH
				+ " in write mode")
		return
	
	f.store_string(SHEBANG + %ShellTxt.text + "\n")
	f.store_string(content)


# func _register_history(command: String) -> void:
# 	_input_history += command


func abort() -> void:
	%PipedShell.abort()


func append_console(text: String) -> void:
	# %Console.text += text
	%Console.append_text(text)


func empty_console() -> void:
	%Console.text = ""


func error(msg: String) -> void:
	printerr(msg)
	var ed := %ErrorDialog
	ed.title = "Error"
	ed.dialog_text = msg
	ed.popup_centered()


func delay_input() -> void:
	_in_input_delay = true
	await get_tree().create_timer(INPUT_DELAY_SEC).timeout
	_in_input_delay = false


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
