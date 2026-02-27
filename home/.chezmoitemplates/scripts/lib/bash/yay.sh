declare -a YAY_INSTALLED=()
yay_cache_loaded=0

yay_load_packages() {
	if [[ $yay_cache_loaded -eq 1 ]]; then
		return
	fi

	yay_cache_loaded=1
	local output
	if ! output=$(yay -Qm 2>/dev/null); then
		YAY_INSTALLED=()
		return
	fi

	while IFS= read -r line; do
		if [[ -n "$line" ]]; then
			local pkg="${line%% *}"
			if [[ -n "$pkg" ]]; then
				YAY_INSTALLED+=("$pkg")
			fi
		fi
	done <<<"$output"
}

yay_package_installed() {
	local package="$1"
	yay_load_packages

	for existing in "${YAY_INSTALLED[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

yay_install_package() {
	local package="$1"

	if yay_package_installed "$package"; then
		print_skip "$package is already installed via yay (skipping)"
		record_skipped
		return
	fi

	print_success "Installing (yay): $package"
	if yay -S --noconfirm "$package"; then
		record_installed
	else
		print_error "Failed to install $package (yay)"
		record_failed "yay" "$package"
	fi
}

yay_version_line() {
	local line
	line=$(yay --version 2>/dev/null || true)
	line="${line%%$'\n'*}"
	if [[ -z "$line" ]]; then
		line="unknown"
	fi
	printf '%s\n' "$line"
}
