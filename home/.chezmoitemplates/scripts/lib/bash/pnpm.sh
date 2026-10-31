declare -a PNPM_INSTALLED=()
pnpm_cache_loaded=0

pnpm_load_packages() {
	if [[ $pnpm_cache_loaded -eq 1 ]]; then
		return
	fi

	pnpm_cache_loaded=1
	local output
	if ! output=$(mise exec -- pnpm ls -g --depth=0 2>/dev/null); then
		PNPM_INSTALLED=()
		return
	fi

	while IFS= read -r pkg; do
		if [[ -n "$pkg" ]]; then
			PNPM_INSTALLED+=("$pkg")
		fi
	done < <(printf '%s\n' "$output" | rg -N '^[@a-z]' | rg -o '^\S+' | rg -v '^dependencies:$')
}

pnpm_package_installed() {
	local package="$1"
	pnpm_load_packages

	for existing in "${PNPM_INSTALLED[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

pnpm_install_package() {
	local package="$1"

	if pnpm_package_installed "$package"; then
		print_skip "$package is already installed via pnpm (skipping)"
		record_skipped
		return
	fi

	print_info "Installing (pnpm): $package"
	if mise exec -- pnpm add -g "$package"; then
		record_installed
	else
		print_error "Failed to install $package (pnpm)"
		record_failed "pnpm" "$package"
	fi
}
