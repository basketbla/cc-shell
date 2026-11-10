# Sourced into the interactive zsh that cc-shell starts.
typeset -g _ccsh_started=0

typeset -ga _ccsh_english=(what who look write yes say talk last from units leave wall mail
  if then else do done while until for select help)

_ccsh_is_claude() {
  local line=${1##[[:space:]]#}
  [[ -z $line ]] && return 1
  [[ $line == \?* || $line == *\? ]] && return 0       # ?forces Claude; questions too
  local -a w; w=(${(z)line})
  while [[ ${w[1]} =~ '^[A-Za-z_][A-Za-z0-9_]*=' ]]; do shift w; done   # FOO=1 cmd
  (( ${#w} )) || return 1
  local first=${(Q)w[1]}
  [[ $first == */* || -d $first ]] && return 1          # paths, auto_cd
  # Real commands (or shell keywords) that almost always start a sentence instead.
  if (( ${_ccsh_english[(Ie)${first:l}]} )) && [[ $line != *[\;\|\&\$\*\(\)\{\}\[\]=]* ]]; then
    return 0
  fi
  [[ $(whence -w -- $first 2>/dev/null) == *": none" || -z $(whence -w -- $first 2>/dev/null) ]]
}

_ccsh_ask() {
  local text=${1#\?}; text=${text##[[:space:]]#}
  local recent=$(fc -ln -12 -1 2>/dev/null)
  local sys="You are running inside cc-shell: the user's own terminal, where any line that is not a shell command is sent to you. Your reply prints inline in their shell, so keep it short and plain (no headings, minimal markdown). The user's shell cwd is $PWD. Their recent shell commands (output not captured; ask or rerun if you need it):
$recent"
  local -a flags
  if (( _ccsh_started )); then flags=(--resume $CC_SHELL_SESSION); else flags=(--session-id $CC_SHELL_SESSION); fi
  _ccsh_started=1
  claude -p "$text" $flags --append-system-prompt "$sys" \
    --output-format stream-json --verbose --include-partial-messages </dev/null 2>&1 \
    | python3 -u "$CC_SHELL_HOME/render.py"
}

_ccsh_accept() {
  if [[ $CONTEXT == start ]] && _ccsh_is_claude "$BUFFER"; then
    local line=$BUFFER
    print -s -- "$line"
    zle -I
    BUFFER=""
    _ccsh_ask "$line"
    return
  fi
  zle .accept-line
}
zle -N _ccsh_accept
bindkey '^M' _ccsh_accept
bindkey '^J' _ccsh_accept

# Open this conversation in the full Claude Code UI (approvals, /commands, etc.).
cc-open() { claude --resume $CC_SHELL_SESSION; }
# Start a fresh conversation.
cc-new() { CC_SHELL_SESSION=$(uuidgen | tr A-Z a-z); _ccsh_started=0; print "new Claude session"; }

PS1="%F{208}cc%f $PS1"
print -P "%F{208}cc-shell%f: commands run as usual, anything else goes to Claude. %F{8}?text forces Claude · cc-new · cc-open · exit%f"
