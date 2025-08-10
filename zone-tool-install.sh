#!/usr/bin/env bash
# --------------------------------------------------------------
#   zone‑import bootstrap installer – works on Debian/Ubuntu
#   (including WSL) even when the system Python is “externally‑managed”.
#   Now also supports Docker for development portability.
# --------------------------------------------------------------
set -euo pipefail

# ---------- Helper functions ----------
log()   { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }
error() { log "ERROR: $*" >&2; exit 1; }

# ---------- Docker option ----------
if command -v docker >/dev/null 2>&1; then
    log "Docker detected. You can run zone-import in a container for portability."
    log "To build the image:   docker build -t zone-import ."
    log "To run the tool:      docker run --rm -it zone-import [arguments]"
    log "To run interactively: docker run --rm -it zone-import"
fi

# ---------- Detect platform ----------
case "$(uname -s)" in
    Linux*)   PLATFORM="linux" ;;
    Darwin*)  PLATFORM="macos" ;;
    *)        error "Unsupported OS: $(uname -s)." ;;
esac
log "Detected platform: $PLATFORM"

# ---------- Choose install locations ----------
INSTALL_DIR="${HOME}/.local/bin"
VENV_DIR="${HOME}/.local/zone-import-venv"
mkdir -p "$INSTALL_DIR"
log "Install directory: $INSTALL_DIR"
log "Virtual‑env directory: $VENV_DIR"

# ---------- Locate Python ----------
if command -v python3 >/dev/null 2>&1; then
    PYTHON="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON="python"
else
    error "Python interpreter not found – please install python3 first."
fi
log "Using Python interpreter: $PYTHON"

# ---------- Detect “externally‑managed” (PEP 668) ----------
EXTERNALLY_MANAGED_FLAG=0
if [[ -f "$(python3 - <<'PY'
import sys, sysconfig, pathlib, json, os
base = sysconfig.get_paths()["stdlib"]
print(os.path.join(base, "EXTERNALLY-MANAGED"))
PY
)" ]]; then
    EXTERNALLY_MANAGED_FLAG=1
fi

# ---------- Create (or reuse) a virtual environment ----------
if [[ $EXTERNALLY_MANAGED_FLAG -eq 1 ]]; then
    log "System Python is externally‑managed – using a private virtualenv."
    if [[ ! -d "$VENV_DIR" ]]; then
        log "Creating virtualenv at $VENV_DIR ..."
        "$PYTHON" -m venv "$VENV_DIR"
    else
        log "Virtualenv already exists – re‑using it."
    fi
    # Activate it for the remainder of the script
    # (activation just sets $VENV_DIR/bin in $PATH and defines $VENV_PYTHON)
    VENV_PYTHON="${VENV_DIR}/bin/python"
    VENV_PIP="${VENV_DIR}/bin/pip"
else
    log "System Python is not externally‑managed – using the interpreter directly."
    VENV_PYTHON="$PYTHON"
    VENV_PIP="$(command -v pip3 || command -v pip)"
fi

# ---------- Upgrade pip (quietly) ----------
log "Ensuring pip is up‑to‑date ..."
"$VENV_PYTHON" -m pip install --quiet --upgrade pip

# ---------- Install required libraries ----------
log "Installing Python dependencies (dnspython, requests) ..."
"$VENV_PIP" install --quiet dnspython requests

# ---------- Write the zone‑import Python program ----------
ZONE_SCRIPT="${INSTALL_DIR}/zone-import"
log "Writing zone‑import script to $ZONE_SCRIPT"
cat > "$ZONE_SCRIPT" <<'EOF_PYTHON'
...existing code...
EOF_PYTHON

chmod +x "$ZONE_SCRIPT"

# ---------- Also output the Python script for Docker ----------
PY_SCRIPT="zone-import.py"
log "Writing zone-import Python script for Docker to $PY_SCRIPT"
cat > "$PY_SCRIPT" <<'EOF_PYTHON'
...existing code...
EOF_PYTHON

# ---------- Ensure the wrapper uses the venv python ----------
if [[ $EXTERNALLY_MANAGED_FLAG -eq 1 ]]; then
    sed -i "1 s|^#\!.*|#\!${VENV_PYTHON}|" "$ZONE_SCRIPT"
fi

# ---------- Add install dir to PATH for the current session ----------
export PATH="${INSTALL_DIR}:$PATH"

# ---------- Add to user’s shell rc if not already there ----------
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    case "$SHELL" in
        */bash)   RC_FILE="${HOME}/.bashrc" ;;
        */zsh)    RC_FILE="${HOME}/.zshrc" ;;
        *)        RC_FILE="${HOME}/.profile" ;;
    esac
    log "Adding $INSTALL_DIR to PATH in $RC_FILE"
    {
        echo ''
        echo '# Added by zone‑import installer (adds user‑local bin to PATH)'
        echo "export PATH=\"${INSTALL_DIR}:\$PATH\""
    } >> "$RC_FILE"
    log ">>> Restart your terminal or run: source $RC_FILE"
fi

log "✅ Installation complete!"
log "You can now run: zone-import"
log "Run \"zone-import -h\" for usage information."
log "Or use Docker: docker run --rm -it zone-import"
