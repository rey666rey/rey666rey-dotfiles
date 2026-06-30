export PATH="/usr/bin:$PATH"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/npm-global/bin:$PATH"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="dd.mm.yyyy"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
git
archlinux
zsh-autosuggestions
zsh-syntax-highlighting
dirhistory
# zsh-wakatime
# docker
# poetry
# golang
)


source $ZSH/oh-my-zsh.sh


# User configuration

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Aliases
if [ -x "$(command -v lsd)" ]; then
    alias ls="lsd"
    alias la="lsd --long --all --group-dirs first"
    alias lt="lsd --tree --group-dirs first"
fi

alias clck="tty-clock -c -s -b -C 7"
alias ff='fastfetch'
alias psu='sudo pacman -Syuu'

alias icat="kitten icat"
alias s="kitten ssh"
alias d="kitten diff"
alias k="kubectl"
alias rmt='trash-put'
alias clean-trash='trash-empty 30'

export OPENROUTER_API_KEY="sk-ea1394d7db004dc7-20a9bb-cb7d663a"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/rey/google-cloud-sdk/path.zsh.inc' ]; then . '/home/rey/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/rey/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/rey/google-cloud-sdk/completion.zsh.inc'; fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/rey/.lmstudio/bin"
# End of LM Studio CLI section


. "$HOME/.local/share/../bin/env"
