#
# Helper Functions
#
zle-line-init() {
	zle -K viins
	echo -ne "\e[5 q"
}

# Vim Cursor shape
# This could be archived with oh-my-zsh
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] ||
	   [[ $1 = 'block' ]]; then
	  echo -ne '\e[1 q'
	elif [[ ${KEYMAP} == main ]] ||
	     [[ ${KEYMAP} == viins ]] ||
	     [[ ${KEYMAP} == '' ]]; then
	  echo -ne '\e[5 q'
	fi
}

# Vim copy and paste fix in terminal
function x11-clip-wrap-widgets() {
    local copy_or_paste=$1
    shift
    for widget in $@; do
        if [[ $copy_or_paste == "copy" ]]; then
            eval "
            function _x11-clip-wrapped-$widget() {
                zle .$widget
                xclip -in -selection clipboard <<<\$CUTBUFFER
            }
            "
        else
            eval "
            function _x11-clip-wrapped-$widget() {
                CUTBUFFER=\$(xclip -out -selection clipboard)
                zle .$widget
            }
            "
        fi
        zle -N $widget _x11-clip-wrapped-$widget
    done
}

# Vim copy and paste fix in terminal
function wld-clip-wrap-widgets() {
    local copy_or_paste=$1
    shift
    for widget in $@; do
        if [[ $copy_or_paste == "copy" ]]; then
            eval "
            function _wld-clip-wrapped-$widget() {
                zle .$widget
                wl-copy <<<\$CUTBUFFER
            }
            "
        else
            eval "
            function _wld-clip-wrapped-$widget() {
                CUTBUFFER=\$(wl-paste)
                zle .$widget
            }
            "
        fi
        zle -N $widget _wld-clip-wrapped-$widget
    done
}

local copy_widgets=(
    vi-yank vi-yank-eol vi-delete vi-backward-kill-word vi-change-whole-line
)
local paste_widgets=(
    vi-put-{before,after}
)


#
# Style
#

# Set style for completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # Case insensitive completion
zmodload zsh/complist
_comp_options+=(globdots)

# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# Set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# Switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# Set default Vim Cursor shape
zle -N zle-keymap-select
zle -N zle-line-init
echo -ne '\e[5 q'

# Copy to wayland clipboard
wld-clip-wrap-widgets copy $copy_widgets
wld-clip-wrap-widgets paste  $paste_widgets


# Enable colors
autoload -U colors && colors

#
# Keybindings
#

# Enable vi mode
bindkey -v
export KEYTIMEOUT=1

# Vim bindings in tab mode
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

#
# Additional Features
#

# Load alias
#[ -f "$XDG_CONFIG_HOME/shell/aliasrc" ] && source "$XDG_CONFIG_HOME/shell/aliasrc" # Load aliases

# Load functions
#[ -f "$XDG_CONFIG_HOME/shell/functionrc" ] && source "$XDG_CONFIG_HOME/shell/functionrc"

# Load functions
#[ -f "$XDG_CONFIG_HOME/shell/suffixaliasrc" ] && source "$XDG_CONFIG_HOME/shell/suffixaliasrc"

# Disable ctrl-s and ctrl-q.
stty -ixon

setopt autocd autopushd \

# Plugin: command-not-found-handler
#source /usr/share/doc/pkgfile/command-not-found.zsh

# Plugin: fuzzy completion
#source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh

# Enable compinit
autoload -Uz compinit && compinit

# Enable autosuggestions
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept


# Load fast-syntax-highlighting; should be last.
#source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

#preexec() { echo -ne '\e[5 q' ;}

#eval "$(starship init zsh)"

# starting commands in background
function background() {
  for ((i=2;i<=$#;i++)); do; ${@[1]} ${@[$i]} &> /dev/null &| ; done
}

# fzf
function src() {
  find ~/.config/* ~/.local/bin/* -type f | fzf | xargs -r $EDITOR ;
}

function srd() {
  find ~/sync/* -type f | grep ".pdf" | fzf | xargs -r $READER ;
}

if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux attack-session -t $USER || tmux new-session -s $USER
fi

 # Define the function in the custom configuration
function dirhashes() {
  echo "Available directory hashes:"
  echo "~conf: nixos configuration"
  echo "~work: organizational stuf and documents (work)"
  echo "~teac: teaching (work)"
  echo "~temp: templates"
  echo "~rese: research"
  echo "~tool: tools"
  echo "~expr: experiments"
}

function cl() {
      cd "$@" && eza -la --color=auto --group-directories-first
}

alias -s pdf="background zathura"
alias -s xpr="background vivado" # for this vivado must be installed

# set up thefuck
# eval $(thefuck --alias)

eval "$(direnv hook zsh)"

