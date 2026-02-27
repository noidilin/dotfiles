declare -a PACMAN_INSTALLED=()
pacman_cache_loaded=0

pacman_refresh_once=0

pacman_upgrade_once() {
	if [[ $pacman_refresh_once -eq 1 ]]; then
		return
	fi
	pacman_refresh_once=1
	sudo pacman -Syu --noconfirm
}

pacman_load_packages() {
	if [[ $pacman_cache_loaded -eq 1 ]]; then
		return
	fi

	pacman_cache_loaded=1
	local output
	if ! output=$(pacman -Qq 2>/dev/null); then
		print_error "WARNING: Failed to query installed packages (skipping all)"
		PACMAN_INSTALLED=()
		return
	fi

	while IFS= read -r pkg; do
		if [[ -n "$pkg" ]]; then
			PACMAN_INSTALLED+=("$pkg")
		fi
	done <<<"$output"
}

pacman_package_installed() {
	local package="$1"
	pacman_load_packages

	for existing in "${PACMAN_INSTALLED[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

pacman_install_package() {
	local package="$1"

	if pacman_package_installed "$package"; then
		print_skip "$package is already installed (skipping)"
		record_skipped
		return
	fi

	print_success "Installing: $package"
	if sudo pacman -S --noconfirm "$package"; then
		record_installed
	else
		print_error "Failed to install $package"
		record_failed "pacman" "$package"
	fi
}
