#!/usr/bin/env bash
# macOS Bootstrap Script
# Execute via:
#   curl -fsSL https://raw.githubusercontent.com/noidilin/dotfiles/main/init/darwin.sh > init.sh
#   bash init.sh

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

manual_step() {
	local title="$1"
	shift
	echo ""
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
	echo -e "${YELLOW}  MANUAL STEP REQUIRED: $title${RESET}"
	echo -e "${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
	echo ""
	for line in "$@"; do
		echo -e "$line"
	done
	echo ""

	# Ensure we're reading from the terminal, not stdin pipe
	if [ -t 0 ]; then
		read -r -p "Press Enter when ready to continue..."
	else
		# Fallback: read directly from /dev/tty if available
		if [ -e /dev/tty ]; then
			read -r -p "Press Enter when ready to continue..." </dev/tty
		else
			stop_on_error "Cannot read user input - not running in interactive terminal"
		fi
	fi
}

# Banner
clear
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE}  macOS Bootstrap Script for Dotfiles${RESET}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${GRAY}This script will automate the following:${RESET}"
echo -e "${GRAY}  • Install Homebrew package manager${RESET}"
echo -e "${GRAY}  • Install bootstrap tools (git, chezmoi, age)${RESET}"
echo -e "${GRAY}  • Install 1Password apps (desktop + CLI)${RESET}"
echo -e "${GRAY}  • Run chezmoi init with dotfiles repo${RESET}"
echo -e "${GRAY}  • Install Fcitx5-Rime input method${RESET}"
echo -e "${GRAY}  • Download Rime language model (197MB, optional)${RESET}"
echo ""
echo -e "${GRAY}Note: First run may take 5-10 minutes (Xcode CLT installation)${RESET}"
echo ""

# Enforce interactive mode
if [ ! -t 0 ]; then
	echo -e "${RED}═══════════════════════════════════════════════════════════${RESET}"
	echo -e "${RED}  ERROR: This script requires interactive mode${RESET}"
	echo -e "${RED}═══════════════════════════════════════════════════════════${RESET}"
	echo ""
	echo -e "${YELLOW}You ran this script via pipe (curl ... | bash), which won't work.${RESET}"
	echo ""
	echo -e "${WHITE}Please download and run it locally instead:${RESET}"
	echo ""
	echo -e "  ${GRAY}curl -fsSL https://raw.githubusercontent.com/noidilin/dotfiles/main/init/darwin.sh > init.sh${RESET}"
	echo -e "  ${GRAY}bash init.sh${RESET}"
	echo ""
	echo -e "${YELLOW}Why?${RESET}"
	echo -e "  • Homebrew needs to prompt for sudo password"
	echo -e "  • 1Password configuration requires manual steps"
	echo -e "  • Script needs to pause and wait for your input"
	echo ""
	exit 1
fi

# Prerequisites Check
manual_step "Prerequisites Check" \
	"Before continuing, please ensure you have:" \
	"" \
	"  ${WHITE}✓ macOS with internet access${RESET}" \
	"  ${WHITE}✓ GitHub connectivity${RESET}" \
	"  ${WHITE}✓ Age passphrase ready (for decrypting chezmoi encrypted files)${RESET}" \
	"" \
	"Note: You will need to complete these steps manually:" \
	"  • 1Password sign-in and SSH agent setup"

# Step 1: Install Homebrew
print_step "Installing Homebrew package manager..."

if command_exists "brew"; then
	BREW_VERSION=$(brew --version 2>/dev/null | head -1 || echo "unknown")
	print_success "Homebrew is already installed: $BREW_VERSION"
else
	# Install Homebrew (will prompt for sudo if needed)
	if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
		stop_on_error "Failed to install Homebrew" "Check internet connection and try again"
	fi

	# Add Homebrew to PATH for current session
	# Detect architecture and set appropriate Homebrew path
	if [[ $(uname -m) == "arm64" ]]; then
		BREW_PREFIX="/opt/homebrew"
	else
		BREW_PREFIX="/usr/local"
	fi

	# Add to PATH if not already present
	if [[ ":$PATH:" != *":$BREW_PREFIX/bin:"* ]]; then
		export PATH="$BREW_PREFIX/bin:$PATH"
	fi

	# Verify Homebrew is now available
	if ! command_exists "brew"; then
		stop_on_error "Homebrew installation verification failed" \
			"Try running: export PATH=\"$BREW_PREFIX/bin:\$PATH\""
	fi

	BREW_VERSION=$(brew --version 2>/dev/null | head -1 || echo "unknown")
	print_success "Homebrew installed successfully: $BREW_VERSION"
fi

# Step 2: Update Homebrew
print_step "Updating Homebrew..."
if ! brew update; then
	stop_on_error "Homebrew update failed" "Check internet connection"
fi
print_success "Homebrew updated successfully"

# Step 3: Install Bootstrap Packages
print_step "Installing bootstrap packages..."
PACKAGES=("git" "chezmoi" "age")

for pkg in "${PACKAGES[@]}"; do
	if brew list "$pkg" &>/dev/null; then
		print_success "$pkg already installed"
	else
		if ! brew install "$pkg"; then
			stop_on_error "Failed to install $pkg" "Check Homebrew installation"
		fi
		print_success "$pkg installed successfully"
	fi
done

# Step 4: Install 1Password Apps
print_step "Installing 1Password apps..."

# Install 1Password desktop app
if brew list --cask 1password &>/dev/null; then
	print_success "1Password desktop app already installed"
else
	if ! brew install --cask 1password; then
		stop_on_error "Failed to install 1Password desktop app" "Check Homebrew cask setup"
	fi
	print_success "1Password desktop app installed"
fi

# Install 1Password CLI
if brew list 1password-cli &>/dev/null; then
	print_success "1Password CLI already installed"
else
	if ! brew install 1password-cli; then
		stop_on_error "Failed to install 1Password CLI" "Check Homebrew installation"
	fi
	print_success "1Password CLI installed successfully"
fi

# Step 5: Manual 1Password Configuration
manual_step "1Password Configuration" \
	"1Password apps have been installed." \
	"Please complete these steps before continuing:" \
	"" \
	"  ${WHITE}1. Launch 1Password desktop app${RESET}" \
	"  ${WHITE}2. Sign in to your account${RESET}" \
	"  ${WHITE}3. Go to Settings → Developer${RESET}" \
	"  ${WHITE}4. Check 'Use the SSH agent'${RESET}" \
	"  ${WHITE}5. Verify github-mac key exists by running:${RESET}" \
	"     ${GRAY}op item get \"github-mac\" --fields \"public key\"${RESET}" \
	""

# Step 6: Verify 1Password CLI Access
print_step "Verifying 1Password CLI access..."

# Test authentication

if ! op signin && op whoami &>/dev/null; then
	stop_on_error "1Password authentication failed" \
		"Sign in to 1Password desktop app and ensure SSH agent is enabled"
fi

OP_VERSION=$(op --version 2>/dev/null || echo "unknown")
print_success "1Password CLI verified: $OP_VERSION"

# Step 7: Initialize Chezmoi Repository
print_step "Initializing chezmoi repository..."
echo -e "${GRAY}  Using HTTPS URL for initial clone (SSH will work after dotfiles are applied)${RESET}"
echo ""

if ! chezmoi init https://github.com/noidilin/dotfiles.git; then
	stop_on_error "Chezmoi init failed" "Check internet connection"
fi

CHEZMOI_SRC=$(chezmoi source-path)
print_success "Repository cloned to $CHEZMOI_SRC"

# Step 8: Apply Dotfiles
print_step "Applying dotfiles..."
echo -e "${GRAY}  Environment variables configured via chezmoi scriptEnv${RESET}"
echo -e "${GRAY}  Mise-managed tools available via 'mise exec' in scripts${RESET}"
echo ""

if ! chezmoi apply; then
	stop_on_error "Chezmoi apply failed" "Check your age passphrase and try again"
fi

print_success "Dotfiles applied successfully"

# ═══════════════════════════════════════════════════════════
# Chinese Input Method Setup
# ═══════════════════════════════════════════════════════════

# Step 9: Install Fcitx5-Rime
print_step "Installing Fcitx5-Rime input method..."

FCITX5_DOWNLOAD_URL="https://github.com/fcitx-contrib/fcitx5-macos-installer/releases/download/latest/Fcitx5-Rime.zip"
FCITX5_WORK_DIR="/tmp/fcitx5-install"
FCITX5_ZIP_FILE="${FCITX5_WORK_DIR}/Fcitx5-Rime.zip"
FCITX5_INSTALLER_APP="${FCITX5_WORK_DIR}/Fcitx5Installer.app"
FCITX5_INSTALL_SUCCESS=false

# Create work directory
mkdir -p "${FCITX5_WORK_DIR}"
cd "${FCITX5_WORK_DIR}"

# Clean up any existing files
echo -e "  ${GRAY}Preparing installation directory...${RESET}"
rm -rf Fcitx5Installer.app Fcitx5-Rime.zip

# Download installer
echo -e "  ${GRAY}Downloading Fcitx5-Rime installer...${RESET}"
if curl -fsSL "${FCITX5_DOWNLOAD_URL}" -o "${FCITX5_ZIP_FILE}"; then
	print_success "Download complete"

	# Extract
	echo -e "  ${GRAY}Extracting installer...${RESET}"
	if unzip -q "${FCITX5_ZIP_FILE}"; then
		print_success "Extraction complete"
		rm -f "${FCITX5_ZIP_FILE}"

		# Manual installation step
		manual_step "Fcitx5 Installation" \
			"The Fcitx5 installer will now open." \
			"Please complete these steps:" \
			"" \
			"  ${WHITE}1. Click 'Install' in the Fcitx5Installer window${RESET}" \
			"  ${WHITE}2. Wait for installation to complete${RESET}" \
			"  ${WHITE}3. Close the installer when finished${RESET}" \
			"  ${WHITE}4. Configure Fcitx5 in System Settings:${RESET}" \
			"     ${GRAY}* System Settings -> Keyboard -> Input Sources${RESET}" \
			"     ${GRAY}* Add 'Fcitx5' as an input source${RESET}" \
			"     ${GRAY}* Configure keyboard shortcuts as needed${RESET}" \
			"" \
			"${GRAY}Note: Your Rime config is already in ~/.config/rime/${RESET}"

		# Open installer
		if open "${FCITX5_INSTALLER_APP}"; then
			print_success "Installer launched"
			read -r -p "Press Enter once you've completed the installation to clean up temporary files..."

			# Cleanup
			echo -e "  ${GRAY}Cleaning up temporary files...${RESET}"
			rm -rf "${FCITX5_WORK_DIR}"
			print_success "Fcitx5 installation complete"
			FCITX5_INSTALL_SUCCESS=true
		else
			print_error "Failed to open installer"
			echo -e "  ${YELLOW}Please manually open: ${FCITX5_INSTALLER_APP}${RESET}"
		fi
	else
		print_error "Failed to extract installer"
		echo -e "  ${YELLOW}Manual download: ${FCITX5_DOWNLOAD_URL}${RESET}"
	fi
else
	print_error "Failed to download Fcitx5 installer"
	echo -e "  ${YELLOW}Manual download: ${FCITX5_DOWNLOAD_URL}${RESET}"
fi

# Return to home directory
cd "${HOME}"

# Step 10: Download Rime Language Model (Optional, only if Fcitx5 installed successfully)
if [ "$FCITX5_INSTALL_SUCCESS" = true ]; then
	print_step "Setting up Rime language model..."

	RIME_DIR="${HOME}/.config/rime"
	GRAM_FILE="${RIME_DIR}/wanxiang-lts-zh-hans.gram"
	GRAM_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"

	# Create directory if it doesn't exist
	mkdir -p "${RIME_DIR}"

	if [ ! -f "${GRAM_FILE}" ]; then
		echo -e "  ${GRAY}The Wanxiang language model improves Chinese input accuracy (197MB download)${RESET}"
		read -r -p "  Do you want to download the Rime language model now? (y/n) " response

		if [[ "$response" =~ ^[Yy]$ ]]; then
			echo -e "  ${GRAY}Downloading from GitHub...${RESET}"

			if curl -fsSL "${GRAM_URL}" -o "${GRAM_FILE}"; then
				print_success "Rime language model downloaded successfully"
			else
				print_error "Failed to download Rime language model"
				echo -e "  ${YELLOW}You can download it later from: ${GRAM_URL}${RESET}"
			fi
		else
			echo -e "  ${GRAY}Skipped. You can download it later from: ${GRAM_URL}${RESET}"
		fi
	else
		print_success "Rime language model already exists"
	fi
else
	echo -e "\n${GRAY}Skipping Rime language model setup (Fcitx5 installation was not completed)${RESET}"
fi

# Final Summary
echo ""
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE}  Bootstrap Complete!${RESET}"
echo -e "${WHITE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${WHITE}Your dotfiles have been applied successfully.${RESET}"
echo ""
echo -e "What happened:"
echo -e "  ${GRAY}✓ Homebrew package manager installed${RESET}"
echo -e "  ${GRAY}✓ Bootstrap tools installed (git, nushell, chezmoi, age)${RESET}"
echo -e "  ${GRAY}✓ 1Password apps installed and configured${RESET}"
echo -e "  ${GRAY}✓ Dotfiles applied via chezmoi${RESET}"
echo -e "  ${GRAY}✓ Fcitx5-Rime input method installed${RESET}"
echo -e "  ${GRAY}✓ Rime language model setup completed${RESET}"
echo ""
echo -e "Next steps:"
echo -e "  ${WHITE}• Restart your shell to load new configurations${RESET}"
echo -e "  ${WHITE}• Chezmoi will automatically run remaining setup scripts${RESET}"
echo -e "  ${WHITE}• Check ~/.config for your configurations${RESET}"
echo ""
