{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git git-lfs gh git-crypt git-filter-repo
    neovim ripgrep fd fzf jq yq-go bat eza tree tmux direnv starship
    curl wget rsync unzip gnupg openssh autossh coreutils file
    cmake gnumake pkg-config scons uv
    nodejs_24 pnpm bun deno rustup dotnet-sdk opam zig
    awscli2 aws-sam-cli google-cloud-sdk databricks-cli
    postgresql_16 dbmate mongodb-tools
    ffmpeg yt-dlp
    opencode graphite-cli python312Packages.huggingface-hub
  ];
}
