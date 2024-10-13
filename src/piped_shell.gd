class_name PipedShell
extends Node
## PipedShell node is used to launch in a new thread a call
## to `OS.execute_with_pipe` while signaling output from
## stdout and stderr. By default, this assumes it will be
## used with a `RichTextLabel`, but the BBCode formating can
## be disabled with the property `use_bbcode_stderr`.
## Note: in some cases you should not use
## `RichTextLabel.append_text` for the callback as it will
## not interpret the BBCode correctly. A quick fix for that
## can be using a lambda function appending directly like
## `func (t): $RichTextLabel += t`. But since now it reads
## pipes line by line it should be ok.
## FIXME puts all stderr after stdout, use redirect maybe?


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
	
	if _thread.is_alive():
		OS.kill(_pid)
	else:
		_pid = 0
		return
		
	_stdio.close()
	print("killed pid ", _pid)
	_pid = 0
	_thread = null


func run(command: String, args: PackedStringArray = [],
		) -> void:
	abort()
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
	_thread.wait_to_finish.call_deferred()
	abort.call_deferred()
