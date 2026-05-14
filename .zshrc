# --- THEMERCHANT-GADGET.DEV DEFINITIVE IMMUNE ZSHRC v3.0 ---
# OPERATOR: Maro-TheMerchant
# -----------------------------------------------------------

# MASTER SESSION AUTO-ATTACH 
if [ -z "$TMUX" ]; then 
  tmux attach-session -t Master || tmux new-session -s Master 
fi
# 1. Identity & Environment
export PATH="$HOME/.local/bin:$HOME/Scripts/bin:$PREFIX/bin:$PATH"
export EDITOR="nvim"
export MERCHANT_SESSION="$HOME/AI/sessions/default.json"
export GROQ_MODEL="llama-3.3-70b-versatile"
export OLLAMA_MODEL="daemonic:latest"

# 2. History & Intelligence
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000; SAVEHIST=200000
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INTERACTIVE_COMMENTS
autoload -Uz compinit && compinit -C

# 3. Plugins
_P="$HOME/.zsh_plugins"
[[ -f "$_P/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$_P/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$_P/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$_P/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$_P/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "$_P/zsh-history-substring-search/zsh-history-substring-search.zsh"

# 4. Keybindings
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 5. Identity Greeting
_merchant_greeting() {
  printf "\033[1;30m  DEVTARGET: \033[0m\033[0;36mTheMerchant-Gadget.dev\033[0m\n"
  printf "\033[1;30m  OPERATOR:  \033[0m\033[0;32mMaro-TheMerchant\033[0m\n"
}

# 6. Status Banner
_merchant_status() {
  _merchant_greeting
  local groq_s ollama_s proxy_s redis_s
  [[ -s "$HOME/.secrets/GROQ_API_KEY" ]] && groq_s=$'\033[0;32mactive\033[0m' || groq_s=$'\033[1;31mmissing\033[0m'
  curl -s --max-time 1 http://127.0.0.1:11434 > /dev/null 2>&1 && ollama_s=$'\033[0;32mrunning\033[0m' || ollama_s=$'\033[2moffline\033[0m'
  netstat -tlnp 2>/dev/null | grep -q 2080 && proxy_s=$'\033[0;32mon\033[0m' || proxy_s=$'\033[2moff\033[0m'
  redis-cli --no-auth-warning ping 2>/dev/null | grep -q PONG && redis_s=$'\033[0;32mon\033[0m' || redis_s=$'\033[2moff\033[0m'

  printf '\n\033[1;30m  TheMerchantNode\033[0m\n'
  _merchant_greeting
  printf '  \033[1;30mgroq\033[0m %s   \033[1;30mollama\033[0m %s\n' "$groq_s" "$ollama_s"
  printf '  \033[1;30mproxy\033[0m %s   \033[1;30mredis\033[0m %s\n\n' "$proxy_s" "$redis_s"
}

# 7. AI Agent: run (High-Level Sanitizer)
run() {
  local sys="You are a terminal agent. Output ONLY the raw bash command. No markdown, no banners. Target: Android aarch64."
  local raw_cmd=$(ask "$sys. Request: $*")
  
  # CLEANING PROCESS:
  # 1. Remove ANSI color escape codes
  # 2. Strip the '▸ model-name' banner
  # 3. Strip markdown backticks
  local clean_cmd=$(echo "$raw_cmd" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed 's/.*▸ [^ ]* //; s/```bash//g; s/```//g; s/`//g')

  printf "\033[36mAI Proposed Command:\033[0m %s\n" "$clean_cmd"
  printf "\033[33mExecute? [y/N]: \033[0m"
  read -r opt
  if [[ "$opt" =~ ^[Yy]$ ]]; then
    eval "$clean_cmd"
  else
    echo "Aborted."
  fi
}

# 8. UI: Bubbles
_cmd_ran=0
preexec() { _cmd_ran=1; printf "\n\033[38;5;240m╭─ Output ────────────────────────────────────────\033[0m\n"; }
precmd() {
  if [[ $_cmd_ran -eq 1 ]]; then
    printf "\033[38;5;240m╰─────────────────────────────────────────────────\033[0m\n"
    _cmd_ran=0
  fi
}

# 9. Tools & Aliases
alias reload='chmod 644 ~/.zshrc && exec zsh'
alias lock='chmod 444 ~/.zshrc && echo "Node Locked."'
alias unlock='chmod 644 ~/.zshrc && echo "Node Unlocked."'
alias v='nvim'
alias try='_try_func'

_try_func() {
  eval "$*" 2>"$HOME/.logs/last_error" || {
    printf '\033[1;31m  ✗ Command failed. Consulting AI fix...\033[0m\n'
    "$HOME/Scripts/bin/fix" --last
  }
}

ask() { "$HOME/Scripts/bin/ask" "$@"; }
fix() { "$HOME/Scripts/bin/fix" "$@"; }

# 10. Initialization
[[ -o interactive ]] && _merchant_status
eval "$(starship init zsh)"
alias architect-dev='cd ~/architecting && python -m http.server 8000'

# --- THEMERCHANT EXTREMITY STACK ---
alias agent='~/Scripts/bin/agent'
alias snap-clip='termux-clipboard-get > ~/bridge/clip.txt'
alias snap-view='termux-camera-photo ~/bridge/view.jpg && base64 ~/bridge/view.jpg'
alias pulse='~/Scripts/bin/pulse &'
alias host-pwa='architect-public'

# --- THEMERCHANT ENMESHMENT AUTO-START ---
# Use 'node-up' to cleanly start or restart the PWA environment
node-up() {
  printf "\033[33m[Node] Clearing ports and cycling servers...\033[0m\n"
  fuser -k 8000/tcp 8001/tcp 2>/dev/null
  python3 -m http.server 8000 --directory ~/architecting >/dev/null 2>&1 &
  python3 ~/architecting/gateway.py >/dev/null 2>&1 &
  sleep 1
  printf "\033[32m[Node] Architecting UI (8000) & Gateway (8001) are ONLINE.\033[0m\n"
}
export TERMINFO=/data/data/com.termux/files/usr/share/terminfo
export TERMINFO=$PREFIX/share/terminfo
export TERM=xterm-256color
export TERMINFO=$PREFIX/share/terminfo
export TERM=xterm-256color

# Updated Proxy Check for sing-box
_merchant_status() {
  local model_s proxy_s redis_s

  # Ollama / Groq
  curl -s --max-time 1 http://127.0.0.1:11434 > /dev/null 2>&1 && model_s=$'\033[0;32mactive\033[0m' || model_s=$'\033[2moffline\033[0m'

  # Proxy (sing-box on 2080)
  ss -tlnp 2>/dev/null | grep -q ":2080" && proxy_s="on" || { pgrep -f sing-box > /dev/null && proxy_s="on" || proxy_s="off"; }

  # Redis
  redis-cli ping &>/dev/null 2>&1 && redis_s="on" || redis_s="off"

  printf "\n\033[2m  TheMerchantNode\033[0m\n"
  printf "  \033[2mdaemonic:latest\033[0m  ${model_s}   \033[2mproxy\033[0m ${proxy_s}   \033[2mredis\033[0m ${redis_s}\n\n"
}


export CLAUDE_CODE_DISABLE_AUTO_UPDATE=1
alias claude='claude-local'
alias claude-local="proot-distro login debian --env ANTHROPIC_BASE_URL=http://10.37.108.224:11436 --env ANTHROPIC_API_KEY=ollama --env ANTHROPIC_AUTH_TOKEN=ollama --env CLAUDE_CODE_DISABLE_AUTO_UPDATE=1 -- /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code-linux-arm64/claude"

# Load TheMerchant environment
if [ -f "$HOME/.merchant.env" ]; then
  source "$HOME/.merchant.env"
fi



# Claude Code (Termux-pinned alias — bypasses broken native binary)
export DISABLE_AUTOUPDATER=1
alias claude='node /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js'
alias ccr-start='node ~/.claude-code-router/bin/index.js start & disown'
alias ccr-start='node ~/.claude-code-router/bin/index.js start & disown'
export PATH="$HOME/Scripts/bin:$PATH"

# In ~/.termux/boot/start-ollama.sh or manually
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_NUM_PARALLEL=1        # Keep low on mobile
export OLLAMA_FLASH_ATTENTION=1     # If supported
export OLLAMA_HOST=0.0.0.0:11434
export PATH="$HOME/Scripts/bin:$PATH"
export PATH="$HOME/Scripts/bin:$PATH"

# Groq Bridge
export GROQ_API_KEY=$(cat ~/.secrets/GROQ_API_KEY)

alias bridge-start='node ~/Scripts/bin/groq-bridge.js & disown && sleep 1 && echo "[Bridge] Live on :3456"'
alias bridge-stop='pkill -f groq-bridge.js && echo "[Bridge] Stopped"'

groq-claude() {
  export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"
  export ANTHROPIC_API_KEY="dummy"
  export DISABLE_AUTOUPDATER=1
  node /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js "$@"
}

test -e "$HOME/.shellfishrc" && source "$HOME/.shellfishrc"
export PATH=$HOME/bin:$PATH
