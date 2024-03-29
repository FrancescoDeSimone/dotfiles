DEFAULT_USER=`whoami`

PLUGINS=( "https://github.com/joshskidmore/zsh-fzf-history-search"
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-history-substring-search")

__update_plugin(){
    pushd $1
    git pull
    popd
}

source ~/.config/.rc
for i in $PLUGINS; do
    [ -d "/home/${DEFAULT_USER}/git/${i##*/}" ] || git clone ${i} /home/${DEFAULT_USER}/git/${i##*/}
    ( &>/dev/null __update_plugin /home/${DEFAULT_USER}/git/${i##*/} & )
    source /home/${DEFAULT_USER}/git/${i##*/}/${i##*/}.zsh
done


#History
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HYPHEN_INSENSITIVE="true"

#completion
autoload -U colors && colors
autoload -Uz compinit
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' \
        max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' menu yes select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion::complete:*' gain-privileges 1
#zstyle ':completion:*' list-colors "$colour"
zstyle ':completion:*:options' list-colors '=^(-- *)=34'
zstyle ':completion:*:*:kill:*' list-colors '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|nc|rsync):*' hosts '
    reply=( ${=${${(M)${(f)"$(<~/.ssh/config)"}:#Host*}#Host }:#*\**} )'
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# options
setopt \
    append_history \
    auto_cd \
    auto_pushd \
    chase_links \
    complete_aliases \
    extended_glob \
    extended_history \
    hist_ignore_all_dups \
    hist_ignore_dups \
    hist_ignore_space \
    hist_reduce_blanks \
    hist_save_no_dups \
    hist_verify \
    ignore_eof \
    list_types \
    mark_dirs \
    noclobber \
    noflowcontrol \
    path_dirs \
    prompt_percent \
    prompt_subst \
    rm_star_wait \
    share_history \

unsetopt globdots

autoload -Uz tetriscurses

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

#git
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true
# hash changes branch misc
zstyle ':vcs_info:git*' formats "(%s) %12.12i %c%u %b%m"
zstyle ':vcs_info:git*' actionformats "(%s|%a) %12.12i %c%u %b%m"
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-stash
# Show count of stashed changes
function +vi-git-stash() {
    local -a stashes

    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        stashes=$(git stash list 2>/dev/null | wc -l)
        hook_com[misc]+=" (${stashes} stashed)"
    fi
}


#search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

#movement
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

ZSH_FZF_HISTORY_SEARCH_FZF_ARGS="+s +m -x -e --height 40%  --height 20%  --layout reverse --info inline"
[ ! -z $(command -v starship) ] && eval "$(starship init zsh)"
[ ! -z $(command -v kubectl) ] && source <(kubectl completion zsh)
if [ ! -z $(command -v jotter) ];then 
    __jotter_zsh() { jotter }
    zle -N __jotter_zsh
    bindkey '^n' __jotter_zsh
    echo lol
fi
