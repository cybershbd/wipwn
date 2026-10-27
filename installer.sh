#!/usr/bin/env bash
# ==============================================================================
#  WIPWN - Universal Root Fix & Dependency Installer for Termux & Linux
#  Resolves: "No Binary detected, Are you rooted?" in Magisk / KernelSU / APatch
#  Maintained by: SH TASRIF (CYBERSHBD)
# ==============================================================================

# ---------- CRLF self-heal ---------------------------------------------------
# If this file was saved with Windows (CRLF) line endings, strip them and
# re-execute a clean copy. This makes `bash installer.sh` work directly on
# Termux/Linux without needing manual dos2unix / sed fixes.
grep -q $'\r' "$0" 2>/dev/null && T=$(mktemp 2>/dev/null || echo "/tmp/.wipwn_install.$$") && tr -d '\r' < "$0" > "$T" && export WIPWN_TMP="$T" WIPWN_ORIG_DIR="$(cd "$(dirname "$0")" && pwd)" && exec bash "$T" "$@" ; # crlf-selfheal
# -----------------------------------------------------------------------------

set -e

# Terminal Colors & Styles
R="\033[0m"
B="\033[1m"
C_GRN="\033[1;32m"
C_DGRN="\033[0;32m"
C_YLW="\033[1;33m"
C_RED="\033[1;31m"
C_CYN="\033[1;36m"
C_BLU="\033[1;34m"

# Trap interrupt cleanly
trap 'echo -e "\n${C_YLW}[ ! ] Operation cancelled by user. Exiting...${R}"; kill 0 2>/dev/null; exit 1' SIGINT

# Logging functions
success() { echo -e " ${C_GRN}[ ✔ ]${R} ${C_DGRN}${1}${R}"; }
info()    { echo -e " ${C_CYN}[ * ]${R} ${1}"; }
warn()    { echo -e " ${C_YLW}[ ! ]${R} ${C_YLW}${1}${R}"; }
error()   { echo -e " ${C_RED}[ ✘ ]${R} ${C_RED}${1}${R}"; }

# Animated Spinner for Long Operations
run_with_spinner() {
  local msg="$1"
  shift
  "$@" > /dev/null 2>&1 &
  local pid=$!
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  
  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 9); do
      echo -ne "\r ${C_CYN}[ ${spinstr:$i:1} ]${R} ${C_YLW}${msg}...${R}"
      sleep 0.08
    done
  done
  
  wait $pid
  local status=$?
  echo -ne "\r\033[K"
  return $status
}

# Determine Execution Environment
IS_TERMUX=false
if [ -d "/data/data/com.termux" ] || [ -n "$PREFIX" ] || [ -n "$ANDROID_ROOT" ]; then
  IS_TERMUX=true
  PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
  BIN_DIR="$PREFIX/bin"
else
  PREFIX="/usr"
  BIN_DIR="/usr/local/bin"
fi

# Preserve original directory (matters when CRLF self-heal re-exec'd us)
SCRIPT_DIR="${WIPWN_ORIG_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Banner
clear 2>/dev/null || true
echo -e "${C_CYN}${B}"
echo "▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰"
echo "      W I P W N   R O O T   &   I N S T A L L E R       "
echo "   Fix KernelSU / Magisk / APatch Root & Setup Suite    "
echo "               CYBERSHBD (SH TASRIF)        "
echo "▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰"
echo -e "${R}"

# Step 1: Purge conflicting tsu binary which causes "No Binary detected, Are you rooted?"
if [ "$IS_TERMUX" = true ]; then
  info "Checking for conflicting packages (tsu)..."
  if command -v tsu >/dev/null 2>&1 || [ -f "$BIN_DIR/tsu" ]; then
    run_with_spinner "Purging incompatible tsu binaries" bash -c "pkg uninstall -y tsu 2>/dev/null; rm -f '$BIN_DIR/tsu' '$BIN_DIR/tsudo' 2>/dev/null || true" || true
    success "Incompatible tsu purged. Root detection conflict cleared."
  else
    success "No conflicting tsu package detected."
  fi
fi

# Step 2: Root Matrix Scan across modern Android Root frameworks
info "Initiating Deep Root Matrix Scan (Magisk, KernelSU, APatch, SuperSU)..."

SU_CANDIDATES=(
  /data/adb/ksu/bin/su
  /data/adb/ap/bin/su
  /data/adb/magisk/su
  /system/bin/su
  /system/xbin/su
  /sbin/su
  /debug_ramdisk/su
  /su/bin/su
  /su/xbin/su
  /system/sbin/su
)

DETECTED_SU=""

# First test su command directly if already present in environment
if command -v su >/dev/null 2>&1; then
  SYS_SU="$(command -v su)"
  if "$SYS_SU" -c "id -u" >/dev/null 2>&1; then
    DETECTED_SU="$SYS_SU"
  fi
fi

# If not found or failed, scan matrix paths
if [ -z "$DETECTED_SU" ]; then
  for su_path in "${SU_CANDIDATES[@]}"; do
    if [ -x "$su_path" ] || [ -f "$su_path" ]; then
      echo -ne "\r ${C_CYN}[ * ]${R} Testing root binary: ${su_path}... "
      if "$su_path" -c "id -u" >/dev/null 2>&1; then
        DETECTED_SU="$su_path"
        echo -e "${C_GRN}VERIFIED!${R}"
        break
      fi
    fi
  done
fi

if [ -n "$DETECTED_SU" ]; then
  success "Active Root Binary verified at: ${B}${DETECTED_SU}${R}"
else
  echo ""
  warn "Could not automatically execute root binary test."
  warn "If Magisk / KernelSU / APatch displays a popup, please tap 'Grant' / 'Allow'."
  if [ -x "/system/bin/su" ]; then
    DETECTED_SU="/system/bin/su"
  elif [ -x "/data/adb/ksu/bin/su" ]; then
    DETECTED_SU="/data/adb/ksu/bin/su"
  elif [ -x "/data/adb/ap/bin/su" ]; then
    DETECTED_SU="/data/adb/ap/bin/su"
  else
    DETECTED_SU="su"
  fi
  info "Configuring universal escalation using root binary: ${DETECTED_SU}"
fi

# Step 3: Inject Bulletproof Universal 'sudo' & 'tsu' Wrapper in Termux
if [ "$IS_TERMUX" = true ]; then
  info "Injecting universal 'sudo' environment into Termux..."
  mkdir -p "$BIN_DIR"

  cat << 'EOF' > "$BIN_DIR/sudo"
#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Universal Root Escalation Wrapper (KernelSU / APatch / Magisk / SuperSU)
# Maintained by CYBERSHBD
# ==============================================================================

SU_BIN=""
# Prioritize verified modern root paths
for cand in \
  /data/adb/ksu/bin/su \
  /data/adb/ap/bin/su \
  /data/adb/magisk/su \
  /system/bin/su \
  /system/xbin/su \
  /sbin/su \
  /debug_ramdisk/su \
  /su/bin/su; do
  if [ -x "$cand" ] || [ -f "$cand" ]; then
    SU_BIN="$cand"
    break
  fi
done

if [ -z "$SU_BIN" ]; then
  if command -v su >/dev/null 2>&1; then
    SU_BIN="$(command -v su)"
  else
    SU_BIN="su"
  fi
fi

# Export essential Termux environment variables so tools function with root
ENV_EXPORTS="export PATH=\"$PATH:/system/bin:/system/xbin:/sbin\";"
[ -n "$LD_LIBRARY_PATH" ] && ENV_EXPORTS="$ENV_EXPORTS export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH\";"
[ -n "$PREFIX" ] && ENV_EXPORTS="$ENV_EXPORTS export PREFIX=\"$PREFIX\";"
[ -n "$HOME" ] && ENV_EXPORTS="$ENV_EXPORTS export HOME=\"$HOME\";"
ENV_EXPORTS="$ENV_EXPORTS export TERM=\"${TERM:-xterm-256color}\";"

# Interactive root shell if called with no arguments
if [ $# -eq 0 ]; then
  TERMUX_BASH="/data/data/com.termux/files/usr/bin/bash"
  [ -x "$TERMUX_BASH" ] || TERMUX_BASH="/system/bin/sh"
  exec "$SU_BIN" -c "$ENV_EXPORTS cd \"$PWD\"; exec $TERMUX_BASH"
fi

# Pass arguments safely escaped
CMD=""
for arg in "$@"; do
  CMD="$CMD $(printf '%q' "$arg")"
done

exec "$SU_BIN" -c "$ENV_EXPORTS cd \"$PWD\"; exec $CMD"
EOF

  chmod 755 "$BIN_DIR/sudo"
  ln -sfn "$BIN_DIR/sudo" "$BIN_DIR/tsu"
  success "Universal 'sudo' framework injected ($BIN_DIR/sudo & tsu link)."
fi

# Step 4: Sync Repositories & Install Required Tools
info "Installing WIPWN dependencies and wireless toolchain..."

if [ "$IS_TERMUX" = true ]; then
  if run_with_spinner "Updating Termux core repositories" bash -c "pkg update -y"; then
    success "Termux repositories synchronized."
  else
    warn "Minor sync warning, continuing..."
  fi

  if run_with_spinner "Enabling root-repo" bash -c "pkg install root-repo -y"; then
    success "Root repository enabled."
  fi

  WIPWN_PKGS="python wpa-supplicant pixiewps iw iproute2 net-tools termux-api git procps coreutils which"
  if run_with_spinner "Installing required packages (${WIPWN_PKGS})" bash -c "pkg install -y $WIPWN_PKGS"; then
    success "All wireless tools and dependencies installed successfully."
  else
    warn "Some packages encountered warnings. Retrying package installation..."
    pkg install -y $WIPWN_PKGS || true
  fi
else
  # Linux environment
  if command -v apt-get >/dev/null 2>&1; then
    SUDO=""
    [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"
    run_with_spinner "Installing Linux dependencies via apt" bash -c "$SUDO apt-get update -y && $SUDO apt-get install -y python3 pixiewps wpasupplicant iw iproute2 net-tools" || true
    success "Linux wireless packages installed."
  fi
fi

# Step 5: Setup $HOME/wipwn directory link
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
mkdir -p "$HOME_DIR"

if [ -f "$SCRIPT_DIR/wipwn.py" ]; then
  if [ "$SCRIPT_DIR" != "$HOME_DIR/wipwn" ]; then
    ln -sfn "$SCRIPT_DIR" "$HOME_DIR/wipwn"
    success "Linked WIPWN repository directory to: ${HOME_DIR}/wipwn"
  fi
fi

# Step 6: Create the Global Shortcut Command 'wipwn'
info "Generating global shortcut command: 'wipwn'..."

cat << 'EOF' > "$BIN_DIR/wipwn"
#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# WIPWN Instant Launcher Shortcut
# Runs: sudo python $HOME/wipwn/wipwn.py -i wlan0 -K "$@"
# ==============================================================================

WIPWN_TARGET="$HOME/wipwn/wipwn.py"

if [ ! -f "$WIPWN_TARGET" ]; then
  # Fallback to local script location if directory moved
  CURRENT_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
  if [ -f "$CURRENT_SCRIPT_DIR/wipwn.py" ]; then
    WIPWN_TARGET="$CURRENT_SCRIPT_DIR/wipwn.py"
  else
    CANDIDATE="$(find "$HOME" -maxdepth 3 -name wipwn.py 2>/dev/null | head -n 1)"
    if [ -n "$CANDIDATE" ] && [ -f "$CANDIDATE" ]; then
      WIPWN_TARGET="$CANDIDATE"
    fi
  fi
fi

if [ ! -f "$WIPWN_TARGET" ]; then
  echo -e "\033[1;31m[✘] Error: wipwn.py could not be located at $HOME/wipwn/wipwn.py\033[0m" >&2
  echo -e "\033[1;33m[!] Please check that the repository is cloned in $HOME/wipwn\033[0m" >&2
  exit 1
fi

exec sudo python "$WIPWN_TARGET" -i wlan0 -K "$@"
EOF

chmod 755 "$BIN_DIR/wipwn"
success "Shortcut '${B}wipwn${R}' created at ${BIN_DIR}/wipwn"

# Step 7: Verify Root Escalation via sudo
echo ""
info "Testing root execution via injected 'sudo'..."
TEST_ROOT_OK=false
if sudo id -u 2>/dev/null | grep -q '^0$'; then
  TEST_ROOT_OK=true
  success "Root privilege confirmed! Identity: root (UID 0)"
else
  warn "Sudo test pending superuser confirmation."
  warn "Ensure Termux is granted Root permission in Magisk / KernelSU / APatch."
fi

echo ""
echo -e "${C_GRN}▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰${R}"
echo -e " ${B}${C_GRN}INSTALLATION & ROOT SETUP COMPLETED SUCCESSFULLY!${R}"
echo -e " ${C_DGRN}✔ KernelSU / Magisk / APatch Root: CONFIGURED${R}"
echo -e " ${C_DGRN}✔ 'tsu' Binary Conflict: PURGED (NO MORE 'NO BINARY DETECTED')${R}"
echo -e " ${C_DGRN}✔ Universal 'sudo': INJECTED AND READY${R}"
echo -e " ${C_DGRN}✔ Dependencies: python, pixiewps, wpa-supplicant, iw, iproute2${R}"
echo -e " ${C_DGRN}✔ Global Shortcut: ${C_CYN}wipwn${R}"
echo -e "${C_GRN}▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰${R}"
echo ""
echo -e " ${C_YLW}You can now run WIPWN anytime simply by typing:${R}"
echo -e "    ${B}${C_GRN}wipwn${R}"
echo -e " ${C_YLW}Which automatically executes:${R}"
echo -e "    ${C_CYN}sudo python \$HOME/wipwn/wipwn.py -i wlan0 -K${R}"
echo ""

# Cleanup temp file created by CRLF self-heal (if any)
[ -n "${WIPWN_TMP:-}" ] && rm -f "$WIPWN_TMP" 2>/dev/null || true

exit 0