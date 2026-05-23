echo "Session type: $(echo $XDG_SESSION_TYPE)"
echo "WM: $(echo $XDG_CURRENT_DESKTOP)"
echo "Kernel version: $(uname -r)"
echo "CPU: $(lscpu | grep 'Model name:' | sed -E 's/^Model name:[[:space:]]*//')"
echo "GPU: $(lspci -d ::0300 | sed -E 's/.*\[([^]]+)\].*/\1/')"
echo "Distro: $(awk -F'[="]' '/PRETTY_NAME/{print $(NF-1)}' /etc/os-release)"
if which prismlauncher &>/dev/null; then
	echo "PrismLauncher installed correctly"
elif flatpak info org.prismlauncher.PrismLauncher &>/dev/null; then
	echo "PrismLauncher installed via Flatpak"
else
	echo "PrismLauncher not installed"
fi
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
	if ls /usr/local/lib64/waywall-glfw/libglfw.so &>/dev/null; then
		echo "Waywall installed via prebuilt package"
		echo "GLFW patch installed at /usr/local/lib64/waywall-glfw/libglfw.so"
	elif which waywall &>/dev/null; then
		echo "Waywall installed in path not via prebuilt package"
	else
		echo "Waywall not installed or not in path"
	fi
elif [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
	if which resetti &>/dev/null; then
		echo "Resetti installed in path"
	elif find Downloads Desktop | grep /resetti &>/dev/null; then
		echo "Resetti downloaded in Downloads or Desktop folders"
	fi
fi

