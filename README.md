# cc-shell

Your normal zsh, but any line that isn't a shell command goes to Claude Code, and the reply prints inline.

```
cc-shell
cc ➜ ~ git status                 # runs as usual
cc ➜ ~ why is the build failing   # goes to Claude, reply prints right here
cc ➜ ~ ?find the flaky test       # leading ? forces Claude
```

- One Claude session per `cc-shell`. Every message continues it, and it follows you as you `cd`.
- A line goes to Claude when its first word isn't an alias, function, builtin, command, path or directory. It also goes to Claude when it ends in `?`, or starts with a word like `what`/`who`/`say`/`do` that is technically a command but almost always English.
- `cc-open` opens the conversation in the full Claude Code UI. `cc-new` starts a fresh one. `exit` leaves.
- Claude runs with your default permission mode from `~/.claude/settings.json`.

Files: `cc-shell` (launcher: temp ZDOTDIR that sources your `~/.zshrc`, then `cc-shell.zsh`), `cc-shell.zsh` (Enter widget + classifier), `render.py` (stream-json → inline text). Installed via a symlink at `~/.local/bin/cc-shell`.
