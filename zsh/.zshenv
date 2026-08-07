# .zshrc の mise activate はプロンプト経由でしか PATH を張らないため、非対話起動には効かない
export PATH="$HOME/.local/share/mise/shims:$PATH"
