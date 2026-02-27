if [[ -z "${DOTFILES_COLORS_INITIALIZED:-}" ]]; then
	CYAN='\033[36m'
	GREEN='\033[32m'
	YELLOW='\033[33m'
	RED='\033[31m'
	GRAY='\033[90m'
	WHITE='\033[97m'
	RESET='\033[0m'
	DOTFILES_COLORS_INITIALIZED=1
fi

print_header() {
	printf "${YELLOW}=== %s ===${RESET}\n" "$1"
}

print_info() {
	printf "${WHITE}%s${RESET}\n" "$1"
}

print_success() {
	printf "${GREEN}%s${RESET}\n" "$1"
}

print_warn() {
	printf "${YELLOW}%s${RESET}\n" "$1"
}

print_error() {
	printf "${RED}%s${RESET}\n" "$1"
}

print_skip() {
	printf "${GRAY}%s${RESET}\n" "$1"
}

require_command_or_exit() {
	local command_name="$1"
	local error_message="$2"
	local hint_message="${3:-}"

	if command -v "$command_name" &>/dev/null; then
		return 0
	fi

	print_error "$error_message"
	if [[ -n "$hint_message" ]]; then
		print_info "$hint_message"
	fi
	exit 1
}

require_command_or_skip() {
	local command_name="$1"
	local skip_message="$2"

	if command -v "$command_name" &>/dev/null; then
		return 0
	fi

	print_error "$skip_message"
	exit 0
}
