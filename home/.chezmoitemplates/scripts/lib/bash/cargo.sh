declare -a CARGO_PACKAGES=()
cargo_cache_loaded=0

cargo_load_packages() {
	if [[ $cargo_cache_loaded -eq 1 ]]; then
		return
	fi

	cargo_cache_loaded=1
	local output
	if ! output=$(mise exec -- cargo install --list 2>/dev/null); then
		CARGO_PACKAGES=()
		return
	fi

	while IFS= read -r pkg; do
		if [[ -n "$pkg" ]]; then
			CARGO_PACKAGES+=("$pkg")
		fi
	done < <(printf '%s\n' "$output" | rg -N '^\S+\s+v\d' | rg -o '^\S+')
}

cargo_package_installed() {
	local package="$1"
	cargo_load_packages

	for existing in "${CARGO_PACKAGES[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

cargo_install_package() {
	local package="$1"

	if cargo_package_installed "$package"; then
		print_skip "$package is already installed via cargo (skipping)"
		record_skipped
		return
	fi

	print_info "Installing (cargo): $package"
	if mise exec -- cargo install "$package"; then
		record_installed
	else
		print_error "Failed to install $package (cargo)"
		record_failed "cargo" "$package"
	fi
}
