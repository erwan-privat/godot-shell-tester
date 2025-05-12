Godot shell tester
==================

Provides not an interactive shell, but more of a script
tester. You can choose the shebang, and provide a command or
script in the application, and it will execute it with the
`OS.execute_with_pipe` function of Godot 4.

TODO and known bugs
-------------------

- [ ] Bug: entering a shortcut still passes text to the
  TextEdit control.
- [ ] Bug: standard output is displayed entirely before
  standard error.
- [ ] Bug: output is scrambled when two processes are
  launched to fast.
