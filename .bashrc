# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#essentialaliases
alias "cl=clear"
alias "rs=source ~/.bashrc"
alias "E=exit"
#aliasesfile
    if [ -f ~/Scripts/bashaliases.sh ]; then
        source ~/Scripts/bashaliases.sh
    else
        print "Alias file not found"
    fi
#histfilesettings
export HISTIGNORE='history -d*'
HISTSIZE=10000
HISTFILESIZE=10000 
#vi-keys
set -o vi
#prompt
PS1='\u@\h \w > '

#zshstyleautocomp
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
#shopts
shopt -s autocd
    exec {BASH_XTRACEFD}>/dev/null
shopt -s cdspell
shopt -s extglob
    shopt -s dotglob
shopt -s complete_fullquote
    shopt -s direxpand
#verbosity
set +o verbose
#fzf
eval "$(fzf --bash)"
    #cmdhist
    export FZF_CTRL_R_OPTS="
      --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
      --color header:italic
      --header 'Press CTRL-Y to copy command into clipboard'" 
export PATH="$HOME/.local/bin:$PATH"

# FZF video search with Ctrl+F

fzf-video() {
    local file
    # Change to your video directory
    cd "/home/operator/DataForts/ALPHA-II/Z10NA7CH1V35" || return 1
    
    file=$(find . -type f \( -name "*.mkv" -o -name "*.mp4" \) -not -path "*/ALAC/*" -print0 | \
        fzf --read0 \
            --height=50% \
            --border \
            --header="Select a video file (Enter to play, Esc to cancel)" \
            --prompt="🎬 Video > " \
            --exit-0)
    
    if [ -n "$file" ]; then
        echo "▶️  Playing: $(basename "$file")"
        mpv "$file" > /dev/null 2>&1 &
        disown
        echo "✅ Video playing in background"
    else
        echo "❌ No file selected or no videos found"
    fi
    
    # Optionally return to previous directory
    cd - > /dev/null 2>&1
}

# Bind Ctrl+F to the function
bind -x '"\C-f": fzf-video'

# login from console
if [ -z "$DISPLAY" -a $XDG_VTNR -eq 1 ]; then
  startx
fi

export PATH="$HOME/.local/bin:$PATH"
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#essentialaliases
alias "cl=clear"
alias "rs=source ~/.bashrc"
alias "E=exit"
#aliasesfile
    if [ -f ~/Scripts/bashaliases.sh ]; then
        source ~/Scripts/bashaliases.sh
    else
        print "404 Alias file not found"
    fi
#histfilesettings
export HISTIGNORE='history -d*'
HISTSIZE=10000
HISTFILESIZE=10000 
#vi-keys
set -o vi
#prompt
#end=$(tput cup 9999 0)
#PS1='\u@\h \W > '

#zshstyleautocomp
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
#shopts
shopt -s autocd
    exec {BASH_XTRACEFD}>/dev/null
shopt -s cdspell
shopt -s extglob
    shopt -s dotglob
shopt -s complete_fullquote
    shopt -s direxpand
#verbosity
set +o verbose
#fzf
eval "$(fzf --bash)"
    #cmdhist
    export FZF_CTRL_R_OPTS="
      --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
      --color header:italic
      --header 'Press CTRL-Y to copy command into clipboard'" 
export PATH="$HOME/.local/bin:$PATH"

# login from console
if [ -z "$DISPLAY" -a $XDG_VTNR -eq 1 ]; then
  startx
fi

