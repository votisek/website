#! /bin/bash

javaver () {
    local prism_dir="$HOME/.local/share/PrismLauncher"

    local min_playtime=9999999
    target=""
    source=""

    if [[ -n "$prism_dir" ]]; then
        for inst in "$prism_dir/instances"/*; do
            [[ -d "$inst" ]] || continue
            if find "$inst/minecraft/mods" -iname "*stronghold*" -print -quit 2>/dev/null | grep -q .; then
                if [[ -f "$inst/instance.cfg" ]]; then
                    local playtime=$(grep -e '^totalPlayTime=' "$inst/instance.cfg" | cut -d'=' -f2 | tr -d '\r')
                    local javapath=$(grep -e '^JavaPath=' "$inst/instance.cfg" | cut -d'=' -f2 | tr -d '\r')
                    playtime=${playtime:-0}
                    if (( playtime < min_playtime )); then
                        min_playtime=$playtime
                        target=$javapath
                        source=" in instance settings"
                    fi
                fi
            fi
        done
 
        if [[ -z "$target" ]]; then 
            if [[ -f "$prism_dir/prismlauncher.cfg" ]]; then
                target=$(grep '^JavaPath=' "$prism_dir/prismlauncher.cfg" | cut -d'=' -f2 | tr -d '\r')
                source=" in global prism settings"
            fi
        fi
    fi

    if [[ -z "$target" ]]; then 
        target=$(which java 2>/dev/null)
        source=" in global java"
    fi
}

wayland () {
    if [[ -f /usr/local/lib64/waywall-glfw/libglfw.so ]]; then
        echo "Waywall installed via prebuilt package"
        echo "GLFW patch installed at /usr/local/lib64/waywall-glfw/libglfw.so"
    elif which waywall &>/dev/null; then
        echo "Waywall installed in path not via prebuilt package"
    else
        echo "Waywall not installed or not in path"
    fi

    if [[ -f ~/.config/waywall/init.lua ]]; then
        if [[ "$(head -n 1 ~/.config/waywall/config.lua 2>/dev/null)" == "-- ==== WAYWALL GENERIC CONFIG ====" ]]; then
            echo "Waywall has generic config (or some spinoff) installed"
        else
            echo "Waywall has a config installed"
        fi
    else
        echo "No waywall configuration detected"
    fi
}

x11 () {
    if which resetti &>/dev/null; then
        echo "Resetti installed in path"
    elif find ~/Downloads ~/Desktop -name resetti -print -quit 2>/dev/null | grep -q .; then
        echo "Resetti downloaded in Downloads or Desktop folders"
    else
        echo "Resetti not installed"
    fi
}

echo "Session type: $XDG_SESSION_TYPE"
echo "WM: $XDG_CURRENT_DESKTOP"
echo "Kernel version: $(uname -r)"
echo "CPU: $(lscpu | grep 'Model name:' | sed -E 's/^Model name:[[:space:]]*//')"
echo "GPU: $(lspci -d ::0300 | sed -E 's/.*\[([^]]+)\].*/\1/')"

javaver
if [[ -n "$target" ]]; then
    j_version=$("$target" -version 2>&1 | head -n 1)
    echo "Java version: $j_version$source"
else
    echo "Java version: Not found"
fi

echo "Monitor size: $(cat /sys/class/drm/*/modes 2>/dev/null | head -n 1)"
echo "Distro: $(awk -F'[="]' '/PRETTY_NAME/{print $(NF-1)}' /etc/os-release)"

if which prismlauncher &>/dev/null; then
    echo "PrismLauncher installed correctly"
elif flatpak info org.prismlauncher.PrismLauncher &>/dev/null; then
    echo "PrismLauncher installed via Flatpak"
else
    echo "PrismLauncher not installed"
fi

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    wayland
elif [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
    x11
fi
