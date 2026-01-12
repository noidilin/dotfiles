#!/usr/bin/env bash
# Arch Linux WSL2 Bootstrap Script
# Execute via: curl -fsSL https://raw.githubusercontent.com/noidilin/dotfiles/main/init/wsl.sh | bash

set -euo pipefail

# Color codes
YELLOW='\033[33m'
GRAY='\033[90m'
RED='\033[31m'
WHITE='\033[97m'
RESET='\033[0m'

# Helper Functions
print_step() {
	echo -e "\n${YELLOW}▶ $1${RESET}"
}

print_success() {
	echo -e "${GRAY}  ✓ $1${RESET}"
}

print_error() {
	echo -e "${RED}  ✗ $1${RESET}"
}

stop_on_error() {
	local message="$1"
	local hint="${2:-}"
	print_error "$message"
	if [ -n "$hint" ]; then
		echo -e "  ${YELLOW}Hint: $hint${RESET}"
	fi
	exit 1
}

command_exists() {
	command -v "$1" &>/dev/null
}

# Banner
clear
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE}  Arch Linux WSL2 Bootstrap Script for Dotfiles${RESET}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${GRAY}This script will automate the following:${RESET}"
echo -e "${GRAY}  • Verify 1Password access via Windows interop${RESET}"
echo -e "${GRAY}  • Update system packages${RESET}"
echo -e "${GRAY}  • Install bootstrap tools (git, base-devel, openssh, chezmoi, age)${RESET}"
echo -e "${GRAY}  • Install yay AUR helper${RESET}"
echo -e "${GRAY}  • Run chezmoi init with dotfiles repo${RESET}"
echo ""

# Prerequisites: 1Password Verification
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${YELLOW}  Prerequisites Check: 1Password${RESET}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${GRAY}This script requires 1Password to be installed on Windows.${RESET}"
echo -e "${GRAY}Expected setup (should be completed via Windows init/win.ps1):${RESET}"
echo -e "  ${WHITE}✓ 1Password desktop app is installed on Windows${RESET}"
echo -e "  ${WHITE}✓ You are signed in to your 1Password account${RESET}"
echo -e "  ${WHITE}✓ SSH agent is enabled (Settings → Developer → Use the SSH agent)${RESET}"
echo ""
echo -e "${GRAY}Verifying 1Password CLI access via Windows interop...${RESET}"
echo ""

print_step "Verifying 1Password CLI access..."

# Check if op.exe exists
if ! command_exists "op.exe"; then
	stop_on_error "op.exe not found" \
		"Please complete Windows setup first using init/win.ps1 to install 1Password, then restart WSL"
fi

# Test authentication
if ! op.exe whoami &>/dev/null; then
	stop_on_error "1Password authentication failed" \
		"Please sign in to 1Password desktop app on Windows (should be configured via init/win.ps1)"
fi

OP_VERSION=$(op.exe --version 2>/dev/null || echo "unknown")
print_success "1Password CLI verified: $OP_VERSION"

# Step 1: System Update
print_step "Updating system packages..."
if ! sudo pacman -Syu --noconfirm; then
	stop_on_error "System update failed" "Check internet connection and try again"
fi
print_success "System packages updated"

# Step 2: Install Bootstrap Packages
print_step "Installing bootstrap packages..."
PACKAGES=("git" "base-devel" "openssh" "chezmoi" "age")

if ! sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"; then
	stop_on_error "Failed to install bootstrap packages" "Check pacman configuration"
fi

for pkg in "${PACKAGES[@]}"; do
	print_success "$pkg installed"
done

# Step 3: Install yay AUR Helper
print_step "Installing yay AUR helper..."

if command_exists "yay"; then
	YAY_VERSION=$(yay --version 2>/dev/null | head -1 || echo "unknown")
	print_success "yay already installed: $YAY_VERSION"
else
	BUILD_DIR="$HOME/.cache/yay-build"

	# Create build directory
	mkdir -p "$BUILD_DIR"

	# Clean existing build directory if exists
	if [ -d "$BUILD_DIR/yay" ]; then
		print_success "Cleaning existing build directory..."
		rm -rf "$BUILD_DIR/yay"
	fi

	# Clone yay repository
	print_success "Cloning yay repository..."
	if ! git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay" 2>/dev/null; then
		stop_on_error "Failed to clone yay repository" "Check internet connection"
	fi

	# Build and install yay
	print_success "Building and installing yay..."
	if ! (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm); then
		stop_on_error "Failed to build yay" "Check base-devel installation"
	fi

	# Verify installation
	if ! command_exists "yay"; then
		stop_on_error "yay installation verification failed" "Check build logs in $BUILD_DIR/yay"
	fi

	YAY_VERSION=$(yay --version 2>/dev/null | head -1 || echo "unknown")
	print_success "yay installed successfully: $YAY_VERSION"

	# Cleanup build directory
	print_success "Cleaning up build directory..."
	rm -rf "$BUILD_DIR/yay"
fi

# Step 4: Initialize Chezmoi Repository
print_step "Initializing chezmoi repository..."
echo -e "${GRAY}  Using HTTPS URL for initial clone (SSH will work after dotfiles are applied)${RESET}"
echo ""

if ! chezmoi init https://github.com/noidilin/dotfiles.git; then
	stop_on_error "Chezmoi init failed" "Check internet connection"
fi

CHEZMOI_SRC=$(chezmoi source-path)
print_success "Repository cloned to $CHEZMOI_SRC"

# Step 5: Apply Dotfiles
print_step "Applying dotfiles..."
echo -e "${GRAY}  Environment variables configured via chezmoi scriptEnv${RESET}"
echo -e "${GRAY}  Mise-managed tools available via 'mise exec' in scripts${RESET}"
echo ""

if ! chezmoi apply; then
	stop_on_error "Chezmoi apply failed" "Check your age passphrase and try again"
fi

print_success "Dotfiles applied successfully"

# Final Summary
echo ""
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE}  Bootstrap Complete!${RESET}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${WHITE}Your dotfiles have been applied successfully.${RESET}"
echo ""
echo -e "What happened:"
echo -e "  ${GRAY}✓ 1Password CLI access verified${RESET}"
echo -e "  ${GRAY}✓ System packages updated${RESET}"
echo -e "  ${GRAY}✓ Bootstrap tools installed (git, openssh, chezmoi, age)${RESET}"
echo -e "  ${GRAY}✓ yay AUR helper installed${RESET}"
echo ""
echo -e "Next steps:"
echo -e "  ${WHITE}• Restart your shell to load new configurations${RESET}"
echo -e "  ${WHITE}• Chezmoi will automatically run remaining setup scripts${RESET}"
echo -e "  ${WHITE}• Check ~/.config for your configurations${RESET}"
echo ""
