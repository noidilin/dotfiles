# Shared error-policy helper for package scripts.

strict_mode=0
strict_value="${DOTFILES_STRICT:-0}"
case "$strict_value" in
1 | true | TRUE | True | yes | YES | Yes | on | ON | On)
	strict_mode=1
	;;
esac

installed_count=0
skipped_count=0
failed_count=0
declare -a FAILED_ITEMS=()

record_installed() {
	((installed_count += 1))
}

record_skipped() {
	((skipped_count += 1))
}

record_failed() {
	local manager="$1"
	local package="$2"
	((failed_count += 1))
	FAILED_ITEMS+=("${manager}:${package}")

	if [[ $strict_mode -eq 1 ]]; then
		printf "${RED}Strict mode enabled; stopping after failure.${RESET}\n"
		print_summary
		exit 1
	fi
}

print_summary() {
	printf "\n${WHITE}Summary: installed=%d skipped=%d failed=%d${RESET}\n" "$installed_count" "$skipped_count" "$failed_count"
	if [[ $failed_count -gt 0 ]]; then
		printf "${RED}Failed items:${RESET}\n"
		for item in "${FAILED_ITEMS[@]}"; do
			printf "${RED}- %s${RESET}\n" "$item"
		done
	fi
}
