# Disable ctrl-s and ctrl-q.
stty -ixon

setopt autocd autopushd \

# Enable autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

# Enable colors and change prompt
autoload -U colors && colors

source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menu-select '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
bindkey -M menu-select '^ ' autosuggest-accept
zstyle ':autocomplete:*' list-lines 100
zstyle ':autocomplete:*' widget-style menu-select
zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward
zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' recent-dirs zsh-z
zstyle ':autocomplete:*' menu select
zstyle ':autocomplete:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # Case insensitive completion
zstyle ':autocomplete:*' insert-unambiguous yes

# Enable vi mode
bindkey -v
export KEYTIMEOUT=1
# Vim bindings in tab mode
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
# Vim Cursor shape
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
zle -N zle-keymap-select
zle-line-init() {
	zle -K viins
	echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

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


local copy_widgets=(
    vi-yank vi-yank-eol vi-delete vi-backward-kill-word vi-change-whole-line
)
local paste_widgets=(
    vi-put-{before,after}
)

# NB: can atm. only wrap native widgets
x11-clip-wrap-widgets copy $copy_widgets
x11-clip-wrap-widgets paste  $paste_widgets



[ -f "$XDG_CONFIG_HOME/shell/functionrc" ] && source "$XDG_CONFIG_HOME/shell/functionrc"

[ -f "$XDG_CONFIG_HOME/shell/aliasrc" ] && source "$XDG_CONFIG_HOME/shell/aliasrc" # Load aliases

[ -f "$XDG_CONFIG_HOME/shell/suffixaliasrc" ] && source "$XDG_CONFIG_HOME/shell/suffixaliasrc"

eval "$(starship init zsh)"

# Load command-not-found-handler
source /usr/share/doc/pkgfile/command-not-found.zsh

# Load fast-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux attack-session -t $USER || tmux new-session -s $USER
fi

# set up thefuck
eval $(thefuck --alias)

pfetch
