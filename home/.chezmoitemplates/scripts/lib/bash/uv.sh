declare -a UV_TOOLS=()
uv_cache_loaded=0

uv_load_tools() {
	if [[ $uv_cache_loaded -eq 1 ]]; then
		return
	fi

	uv_cache_loaded=1
	local output
	if ! output=$(mise exec -- uv tool list 2>/dev/null); then
		UV_TOOLS=()
		return
	fi

	while IFS= read -r pkg; do
		if [[ -n "$pkg" ]]; then
			UV_TOOLS+=("$pkg")
		fi
	done < <(printf '%s\n' "$output" | rg -N '^\S+\s+v\d' | rg -o '^\S+' | rg -v '^Installed$')
}

uv_tool_installed() {
	local package="$1"
	uv_load_tools

	for existing in "${UV_TOOLS[@]:-}"; do
		if [[ "$existing" == "$package" ]]; then
			return 0
		fi
	done

	return 1
}

uv_install_tool() {
	local package="$1"

	if uv_tool_installed "$package"; then
		print_skip "$package is already installed via uv (skipping)"
		record_skipped
		return
	fi

	print_info "Installing (uv): $package"
	if mise exec -- uv tool install "$package"; then
		record_installed
	else
		print_error "Failed to install $package (uv)"
		record_failed "uv" "$package"
	fi
}
