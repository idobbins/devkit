{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history = { path = "$HOME/.zsh_history"; size = 50000; save = 50000; share = true; };
    shellAliases = {
      g = "git"; ga = "git add"; gaa = "git add --all"; gc = "git commit";
      gcm = "git commit -m"; gco = "git checkout"; gd = "git diff";
      gl = "git pull"; gp = "git push"; gst = "git status";
      grt = ''cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'';
      dk = "devkit"; dka = "devkit apply"; dku = "devkit update";
      dke = "devkit edit"; dks = "devkit status"; dkd = "devkit doctor";
      vim = "nvim"; cat = "bat"; ls = "eza --group-directories-first";
      ll = "eza -la --group-directories-first --git";
    };
    initContent = ''
      setopt prompt_subst auto_cd interactive_comments hist_ignore_dups hist_ignore_space share_history
      export EDITOR="nvim" VISUAL="nvim" PAGER="less" LESS="-R"

      autoload -Uz vcs_info add-zsh-hook
      zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
      zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%f'
      _precmd_vcs_info() { vcs_info; }
      add-zsh-hook precmd _precmd_vcs_info
      PROMPT='%(?.%F{green}➜.%F{red}➜) %F{cyan}%1~%f''${vcs_info_msg_0_} '

      command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

      work() {
        local root="''${DEV_HOME:-$HOME/dev}"
        local query="''${1:-}"
        local dest=""

        if [[ -z "$query" ]]; then
          dest="$root"
        else
          local candidates=("$query" "$root/$query" "$root/i7/$query")
          local candidate
          for candidate in "''${candidates[@]}"; do
            if [[ -d "$candidate" ]]; then
              dest="$candidate"
              break
            fi
          done
        fi

        if [[ -z "$dest" ]]; then
          print -u2 "work: project not found: $query"
          print -u2 "tried: $query, $root/$query, $root/i7/$query"
          return 1
        fi

        cd "$dest" || return
        command -v devkit >/dev/null 2>&1 && devkit project-info .
      }

      [[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
    '';
  };

  programs.fzf.enable = true;
  programs.direnv.enable = true;
}
