extends PanelContainer


func _input(event: InputEvent) -> void:
	if event.is_action("ui_quit"):
		request_quit()
	elif event.is_action("paste"):
		paste_from_clipboard()
	elif event.is_action("run"):
		run()



func paste_from_clipboard() -> void:
	print(get_stack()[0]["function"])


func run() -> void:
	print(get_stack()[0]["function"])


func request_quit() -> void:
	print(get_stack()[0]["function"])
	get_tree().root.propagate_notification(
			NOTIFICATION_WM_CLOSE_REQUEST)
