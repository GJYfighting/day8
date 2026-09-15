#!/usr/bin/env bash
# Source this file before every Day8 command.

DAY8_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAY8_RUNTIME_ROOT="$DAY8_ROOT/runtime"
DAY8_PREVIOUS_NAME="day""7"
DAY8_PREVIOUS_ROOT="$(dirname "$DAY8_ROOT")/$DAY8_PREVIOUS_NAME"

if [[ "${CONDA_SHLVL:-0}" != "0" || -n "${CONDA_PREFIX:-}" ]]; then
  echo "检测到Anaconda环境。请先执行：conda deactivate" >&2
  return 2 2>/dev/null || exit 2
fi

if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  if declare -F deactivate >/dev/null 2>&1; then
    deactivate
  else
    unset VIRTUAL_ENV
  fi
fi

DAY8_CLEAN_PATH=""
IFS=: read -ra DAY8_PATH_PARTS <<<"$PATH"
for DAY8_PATH_PART in "${DAY8_PATH_PARTS[@]}"; do
  [[ "$DAY8_PATH_PART" == *anaconda* || "$DAY8_PATH_PART" == *conda* ]] && continue
  [[ "$DAY8_PATH_PART" == "$DAY8_PREVIOUS_ROOT"* ]] && continue
  [[ "$DAY8_PATH_PART" =~ /day[0-7](/|$|-) ]] && continue
  DAY8_CLEAN_PATH="${DAY8_CLEAN_PATH:+$DAY8_CLEAN_PATH:}$DAY8_PATH_PART"
done
export PATH="/usr/bin:$DAY8_CLEAN_PATH"
unset DAY8_PATH_PART DAY8_PATH_PARTS DAY8_CLEAN_PATH
unset PYTHONHOME
unset PYTHONNOUSERSITE

source /opt/ros/humble/setup.bash
source "$DAY8_ROOT/../install/setup.bash"

DAY8_CLEAN_PYTHONPATH=""
IFS=: read -ra DAY8_PYTHONPATH_PARTS <<<"${PYTHONPATH:-}"
for DAY8_PYTHONPATH_PART in "${DAY8_PYTHONPATH_PARTS[@]}"; do
  [[ "$DAY8_PYTHONPATH_PART" == "$DAY8_PREVIOUS_ROOT"* ]] && continue
  [[ "$DAY8_PYTHONPATH_PART" =~ /day[0-7](/|$|-) ]] && continue
  DAY8_CLEAN_PYTHONPATH="${DAY8_CLEAN_PYTHONPATH:+$DAY8_CLEAN_PYTHONPATH:}$DAY8_PYTHONPATH_PART"
done
export PYTHONPATH="$DAY8_ROOT/vendor:$DAY8_ROOT${DAY8_CLEAN_PYTHONPATH:+:$DAY8_CLEAN_PYTHONPATH}"
unset DAY8_PYTHONPATH_PART DAY8_PYTHONPATH_PARTS DAY8_CLEAN_PYTHONPATH
unset DAY8_PREVIOUS_NAME DAY8_PREVIOUS_ROOT

mkdir -p \
  "$DAY8_ROOT/results" \
  "$DAY8_RUNTIME_ROOT/ros-home" \
  "$DAY8_RUNTIME_ROOT/logs/ros" \
  "$DAY8_RUNTIME_ROOT/logs/check" \
  "$DAY8_RUNTIME_ROOT/ignition/log" \
  "$DAY8_RUNTIME_ROOT/ignition/fuel" \
  "$DAY8_RUNTIME_ROOT/pycache" \
  "$DAY8_RUNTIME_ROOT/xdg/cache" \
  "$DAY8_RUNTIME_ROOT/xdg/config" \
  "$DAY8_RUNTIME_ROOT/xdg/data" \
  "$DAY8_RUNTIME_ROOT/matplotlib" \
  "$DAY8_RUNTIME_ROOT/qml-cache" \
  "$DAY8_RUNTIME_ROOT/torch" \
  "$DAY8_RUNTIME_ROOT/cuda-cache" \
  "$DAY8_RUNTIME_ROOT/tmp"

export DAY8_ROOT DAY8_RUNTIME_ROOT
export DAY8_PYTHON=/usr/bin/python3
export CAMERA_TYPE=GEMINI
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
export QT_X11_NO_MITSHM="${QT_X11_NO_MITSHM:-1}"
export ROS_DOMAIN_ID="${DAY8_ROS_DOMAIN_ID:-90}"
export IGN_PARTITION="${DAY8_IGN_PARTITION:-day8_${USER}}"
# All Day8 simulator and CLI processes are local; avoid VM NIC discovery.
export IGN_IP="${DAY8_IGN_IP:-127.0.0.1}"
export ROS_HOME="$DAY8_RUNTIME_ROOT/ros-home"
export ROS_LOG_DIR="$DAY8_RUNTIME_ROOT/logs/ros"
export IGN_LOG_PATH="$DAY8_RUNTIME_ROOT/ignition/log"
export IGN_FUEL_CACHE_PATH="$DAY8_RUNTIME_ROOT/ignition/fuel"
export PYTHONPYCACHEPREFIX="$DAY8_RUNTIME_ROOT/pycache"
export XDG_CACHE_HOME="$DAY8_RUNTIME_ROOT/xdg/cache"
export XDG_CONFIG_HOME="$DAY8_RUNTIME_ROOT/xdg/config"
export XDG_DATA_HOME="$DAY8_RUNTIME_ROOT/xdg/data"
export MPLCONFIGDIR="$DAY8_RUNTIME_ROOT/matplotlib"
export QML_DISK_CACHE_PATH="$DAY8_RUNTIME_ROOT/qml-cache"
export TORCH_HOME="$DAY8_RUNTIME_ROOT/torch"
export CUDA_CACHE_PATH="$DAY8_RUNTIME_ROOT/cuda-cache"
export TMPDIR="$DAY8_RUNTIME_ROOT/tmp"

export XDG_RUNTIME_DIR="$DAY8_RUNTIME_ROOT/xdg/run"
mkdir -p "$XDG_RUNTIME_DIR" "$DAY8_RUNTIME_ROOT/home"
chmod 700 "$XDG_RUNTIME_DIR"
export DAY8_APPLICATION_HOME="$DAY8_RUNTIME_ROOT/home"
# A Ruby shim is required because ros_gz_sim invokes `ruby <ign executable>`.
# Give Ignition a real private application home without repurposing shell HOME.
mkdir -p "$DAY8_RUNTIME_ROOT/bin"
DAY8_IGN_SHIM_TMP="$(mktemp "$DAY8_RUNTIME_ROOT/bin/.ign.XXXXXX")"
cat > "$DAY8_IGN_SHIM_TMP" <<'DAY8_IGN_RUBY'
#!/usr/bin/ruby
ENV["HOME"] = ENV.fetch("DAY8_APPLICATION_HOME")
load "/usr/bin/ign"
DAY8_IGN_RUBY
chmod 755 "$DAY8_IGN_SHIM_TMP"
mv -f "$DAY8_IGN_SHIM_TMP" "$DAY8_RUNTIME_ROOT/bin/ign"
unset DAY8_IGN_SHIM_TMP
export PATH="$DAY8_RUNTIME_ROOT/bin:$PATH"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export IGN_HOMEDIR="$DAY8_RUNTIME_ROOT/home"
export GZ_HOMEDIR="$DAY8_RUNTIME_ROOT/home"
export TMP="$TMPDIR" TEMP="$TMPDIR"
export PYTHONDONTWRITEBYTECODE=1
export NUMBA_CACHE_DIR="$DAY8_RUNTIME_ROOT/numba"
export TRITON_CACHE_DIR="$DAY8_RUNTIME_ROOT/triton"
export __GL_SHADER_DISK_CACHE_PATH="$DAY8_RUNTIME_ROOT/gl-cache"
cd "$DAY8_ROOT"

echo "DAY8_ENV=READY"
echo "ROOT=$DAY8_ROOT"
echo "ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
echo "IGN_PARTITION=$IGN_PARTITION"
echo "PYTHON=$DAY8_PYTHON"
