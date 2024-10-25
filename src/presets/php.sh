#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Define an info message function
info() {
    local blue_bg="\033[44m"
    local white_text="\033[97m"
    local reset="\033[0m"
    printf " ${blue_bg}${white_text} INFO ${reset} $1"
}

# Define a success message function
success() {
    local green_bg="\033[42m"
    local black_text="\033[30m"
    local reset="\033[0m"
    printf " ${green_bg}${black_text} SUCCESS ${reset} $1 \n"
}

# Define an error message
error() {
    local red_bg="\033[41m"
    local white_text="\033[97m"
    local reset="\033[0m"
    printf " ${red_bg}${white_text} ERROR ${reset} $1 \n"
    exit 1
}

# Function to check if script has sudo access and request it if needed
ensure_sudo() {
    if [ "$EUID" -ne 0 ]; then
        info "This script requires sudo privileges to install PHP packages. \n"
        if ! sudo -v; then
            error "Could not acquire sudo privileges"
        fi
    fi
}

# Function to wait until apt package lock is released
wait_for_apt_lock() {
    info "Waiting for apt lock to be released..."
    while sudo fuser /var/lib/apt/lists/lock /var/lib/dpkg/lock >/dev/null 2>&1; do
        sleep 3
    done
}

# Function to determine the appropriate shell profile file to modify PATH
get_profile_file() {
    local shell_name
    shell_name=$(basename "$SHELL")

    # Set the search order for profile files, based on common conventions
    local profile_files=(".bash_profile" ".bashrc" ".profile" ".zshrc")

    # Loop through each profile file, returning the first existing one
    for profile_file in "${profile_files[@]}"; do
        if [[ -f "$HOME/$profile_file" ]]; then
            echo "$HOME/$profile_file"
            return
        fi
    done

    # If no common profile file is found, fallback to ~/.profile
    echo "$HOME/.profile"
}

# Clear screen for readability
clear

# Request sudo access before installation starts
ensure_sudo

# Add PHP repository for the specified PHP version
PHP_VERSION="8.3"
info "Adding PHP repository...\n"
sudo apt-get update -y
sudo apt-get install -y ca-certificates apt-transport-https software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

# Wait for apt lock to be released before proceeding with installations
wait_for_apt_lock
sudo apt-get update -y

# Install PHP with selected extensions
info "Installing PHP and extensions...\n"
sudo apt-get install -y php$PHP_VERSION-fpm \
  php$PHP_VERSION-bcmath \
  php$PHP_VERSION-cli \
  php$PHP_VERSION-curl \
  php$PHP_VERSION-dev \
  php$PHP_VERSION-gd \
  php$PHP_VERSION-igbinary \
  php$PHP_VERSION-imagick \
  php$PHP_VERSION-imap  \
  php$PHP_VERSION-intl \
  php$PHP_VERSION-ldap \
  php$PHP_VERSION-mbstring \
  php$PHP_VERSION-memcached \
  php$PHP_VERSION-msgpack \
  php$PHP_VERSION-mysql \
  php$PHP_VERSION-pcov \
  php$PHP_VERSION-pgsql  \
  php$PHP_VERSION-readline \
  php$PHP_VERSION-redis \
  php$PHP_VERSION-soap \
  php$PHP_VERSION-sqlite3 \
  php$PHP_VERSION-swoole \
  php$PHP_VERSION-xdebug \
  php$PHP_VERSION-xml \
  php$PHP_VERSION-zip \
  zip unzip

# Switch system's default PHP to the newly installed version
sudo update-alternatives --set php /usr/bin/php$PHP_VERSION

# Install Composer
info "Installing Composer...\n"
COMPOSER_DIR="/usr/local/bin"
EXPECTED_CHECKSUM=$(wget -q -O - "https://composer.github.io/installer.sig")
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

# Verify Composer installer checksum for security
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    rm composer-setup.php
    error "Invalid Composer installer signature"
fi

# Run Composer installer, then clean up and set correct permissions
sudo php composer-setup.php --install-dir="$COMPOSER_DIR" --filename=composer
sudo rm composer-setup.php
sudo chmod +x "$COMPOSER_DIR/composer"

# Check if /usr/local/bin is already in PATH, and add it if not
PROFILE_FILE=$(get_profile_file)
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  # Add /usr/local/bin to PATH in the identified profile file
  printf '\nexport PATH="/usr/local/bin:$PATH"\n' >> "$PROFILE_FILE"

  # Notify user about the PATH modification
  info "/usr/local/bin has been added to your PATH in $PROFILE_FILE\n"
fi

# Create uninstall command instructions
UNINSTALL_SCRIPT="sudo apt remove php$PHP_VERSION-*\nsudo rm -rf $COMPOSER_DIR/composer\n"

# Retrieve installed PHP and Composer versions
PHP_VERSION=$(php --version | awk '/^PHP/ {print $2}')
COMPOSER_VERSION=$("$COMPOSER_DIR/composer" --version | awk '{print $3}')

# Display success message with installed versions in a boxed format
printf "\n"
success "PHP and Composer have been installed successfully."
printf "┌─────────────────────────────────────┐\n"
printf "│ PHP: \e[1m%-30s\e[0m │\n" "$PHP_VERSION"
printf "│ Composer: \e[1m%-26s\e[0m│\n" "$COMPOSER_VERSION"
printf "└─────────────────────────────────────┘\n\n"
info "Please restart your terminal or run \e[1m'source $PROFILE_FILE'\e[0m for the changes to take effect.\n\n"

# Display uninstall instructions for PHP and Composer
info "To uninstall PHP and Composer, run the following commands:\n"
printf "$UNINSTALL_SCRIPT"
