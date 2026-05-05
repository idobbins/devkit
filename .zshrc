# Fast, portable zsh config. No Oh My Zsh startup path.

typeset -U path PATH

# Portable user paths first.
for dir in \
  "$HOME/.local/bin" \
  "$HOME/bin" \
  "$HOME/.cargo/bin" \
  "$HOME/.bun/bin" \
  "$HOME/.deno/bin" \
  "/opt/homebrew/bin" \
  "/usr/local/bin"
do
  [[ -d "$dir" ]] && path=("$dir" $path)
done
unset dir

setopt prompt_subst
setopt auto_cd
setopt interactive_comments
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"

# Custom completions
fpath=(
  "$HOME/.zsh/completions"
  "$HOME/.oh-my-zsh/custom/completions"
  $fpath
)

# Fast completion init.
# If completions ever seem stale, run:
#   rm ~/.zcompdump-fast-*
autoload -Uz compinit
compinit -C -d "$HOME/.zcompdump-fast-${ZSH_VERSION}"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Prompt: robbyrussell-ish, but without OMZ
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'

_precmd_vcs_info() {
  vcs_info
}
add-zsh-hook precmd _precmd_vcs_info

PROMPT='%(?.%F{green}➜.%F{red}➜) %F{cyan}%1~%f${vcs_info_msg_0_} '

# Minimal git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias grt='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'

# Common quality-of-life aliases when tools are installed
command -v nvim >/dev/null 2>&1 && alias vim='nvim'
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v eza >/dev/null 2>&1 && alias ls='eza --group-directories-first'
command -v eza >/dev/null 2>&1 && alias ll='eza -la --group-directories-first --git'

# pnpm home differs by platform/installer. Add both if present.
for dir in "$HOME/Library/pnpm" "$HOME/.local/share/pnpm"; do
  [[ -d "$dir" ]] && path=("$dir" $path)
done
unset dir

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# fzf shell integration
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh) 2>/dev/null || true
fi

# Machine-local overrides/secrets. Keep this file untracked.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Lazy nvm. Keeps shell startup fast while exposing the default Node on PATH.
export NVM_DIR="$HOME/.nvm"

if [[ -r "$NVM_DIR/alias/default" ]]; then
  nvm_default_version="$(<"$NVM_DIR/alias/default")"
  nvm_default_bin="$NVM_DIR/versions/node/$nvm_default_version/bin"
  [[ -d "$nvm_default_bin" ]] && path=("$nvm_default_bin" $path)
  unset nvm_default_version nvm_default_bin
fi

nvm() {
  unset -f nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Autosuggestions
[[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting must be last
[[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
