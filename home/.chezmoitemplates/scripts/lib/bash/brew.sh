declare -a BREW_FORMULAE=()
declare -a BREW_CASKS=()
brew_cache_loaded=0
brew_updated=0

brew_update_once() {
	if [[ $brew_updated -eq 1 ]]; then
		return
	fi

	brew_updated=1
	print_warn "Updating Homebrew..."
	brew update
}

brew_load_packages() {
	if [[ $brew_cache_loaded -eq 1 ]]; then
		return
	fi

	brew_cache_loaded=1
	local output

	if ! output=$(brew list --formula 2>/dev/null); then
		print_error "WARNING: Failed to query installed formulae"
		BREW_FORMULAE=()
	else
		while IFS= read -r pkg; do
			if [[ -n "$pkg" ]]; then
				BREW_FORMULAE+=("$pkg")
			fi
		done <<<"$output"
	fi

	if ! output=$(brew list --cask 2>/dev/null); then
		print_error "WARNING: Failed to query installed casks"
		BREW_CASKS=()
	else
		while IFS= read -r pkg; do
			if [[ -n "$pkg" ]]; then
				BREW_CASKS+=("$pkg")
			fi
		done <<<"$output"
	fi
}

brew_formula_installed() {
	local package="$1"
	brew_load_packages

	for existing in "${BREW_FORMULAE[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

brew_cask_installed() {
	local package="$1"
	brew_load_packages

	for existing in "${BREW_CASKS[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

brew_install_package() {
	local full_spec="$1"
	local package_name=""
	local name_only=""

	if [[ "$full_spec" == "--cask "* ]]; then
		package_name="${full_spec#--cask }"
		name_only="${package_name%% *}"
		name_only="${name_only##*/}"

		if brew_cask_installed "$name_only"; then
			print_skip "$name_only (cask) is already installed (skipping)"
			record_skipped
			return
		fi

		print_success "Installing cask: $package_name"
		if brew install --cask $package_name; then
			record_installed
		else
			print_error "Failed to install cask $package_name"
			record_failed "brew" "$name_only"
		fi
		return
	fi

	package_name="$full_spec"
	name_only="${package_name%% *}"
	name_only="${name_only##*/}"

	if brew_formula_installed "$name_only"; then
		print_skip "$name_only is already installed (skipping)"
		record_skipped
		return
	fi

	print_success "Installing: $package_name"
	if brew install $package_name; then
		record_installed
	else
		print_error "Failed to install $package_name"
		record_failed "brew" "$name_only"
	fi
}
