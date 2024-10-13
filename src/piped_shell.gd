class_name PipedShell
extends Node
## PipedShell node is used to launch in a new thread a call
## to `OS.execute_with_pipe` while printing asynchronously
## stout and stderr with callback `print` function. Assumes
## it will be used with a `RichTextLabel`, but the BBCode
## formating can be disabled with the property
## `use_bbcode_stderr`.
## Note: do not use RichTextLabe.append_text for the
## callback as it will not interpret the BBCode correctly.
## a quick fix for that can be using a lambda function
## appending directly like `func (t): $RichTextLabel += t`.
## TODO add export var to activate auto \n,\r\n appending


signal output(line: String)

@export var use_bbcode_stderr: bool = true
@export var line_ending := "\n"
var _thread: Thread
var _stdio: FileAccess
var _stderr: FileAccess
var _pid: int = 0


func abort():
	if _pid == 0:
		return

	OS.kill(_pid)
	print("killed pid ", _pid)
	_pid = 0
	_thread.wait_to_finish()
	_thread = null
	pass


func run(command: String, args: PackedStringArray = [],
		) -> void:
	abort()
	assert(_thread == null)
	_thread = Thread.new()
	_thread.start(_shell.bind(command, args))


func _shell(command: String, args: PackedStringArray) \
		-> void:
	
	OS.execute("chmod", ["u+x", command])
	var dic := OS.execute_with_pipe(command, args)
	_stdio = dic.stdio
	_stderr = dic.stderr
	_pid = dic.pid

	while _stdio.is_open():
		if _stdio.get_error() == OK:
			var line := _stdio.get_line() + line_ending

			if use_bbcode_stderr:
				line = line.replace("[", "[lb]")

			output.emit.call_deferred(line)
			pass
		else:
			var line := _stderr.get_line()
			if line != "":
				if use_bbcode_stderr:
					line = "[color=#ff8888]" + line + "[/color]"
				output.emit.call_deferred(line + line_ending)
			else:
				break
	clean_thread()
	
func clean_thread():
	_stdio.close()
	OS.kill(_pid)
