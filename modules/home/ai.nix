{ pkgs, ... }:
{
  home.activation.installAiNpmGlobals = ''
    if command -v npm >/dev/null 2>&1; then
      npm install -g @mariozechner/pi-coding-agent @anthropic-ai/claude-code @openai/codex || true
    fi
  '';
}
