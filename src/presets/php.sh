#!/bin/bash

set -euo pipefail

info() {
    local blue_bg="\033[44m"
    local white_text="\033[97m"
    local reset="\033[0m"
    printf " ${blue_bg}${white_text} INFO ${reset} $1"
}

success() {
    local green_bg="\033[42m"
    local black_text="\033[30m"
    local reset="\033[0m"
    printf " ${green_bg}${black_text} SUCCESS ${reset} $1 \n"
}

error() {
    local red_bg="\033[41m"
    local white_text="\033[97m"
    local reset="\033[0m"
    printf " ${red_bg}${white_text} ERROR ${reset} $1 \n"
    exit 1
}

# Function to check and request sudo access
ensure_sudo() {
    if [ "$EUID" -ne 0 ]; then
        info "This script requires sudo privileges to install PHP packages. \n"
        if ! sudo -v; then
            error "Could not acquire sudo privileges"
        fi
    fi
}

# Function to wait for the apt lock to be released
wait_for_apt_lock() {
    info "Waiting for apt lock to be released..."
    while sudo fuser /var/lib/apt/lists/lock /var/lib/dpkg/lock >/dev/null 2>&1; do
        sleep 3
    done
}

clear

# Request sudo access before starting installation
ensure_sudo

# Add PHP repository
PHP_VERSION="8.3"
info "Adding PHP repository...\n"
sudo apt-get update -y
sudo apt-get install -y ca-certificates apt-transport-https software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

wait_for_apt_lock
sudo apt-get update -y

# Install PHP and required extensions
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

# Switch to the newly installed PHP version
sudo update-alternatives --set php /usr/bin/php$PHP_VERSION

# Install Composer
info "Installing Composer...\n"
COMPOSER_DIR="/usr/local/bin"
EXPECTED_CHECKSUM=$(wget -q -O - "https://composer.github.io/installer.sig")
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

# Throw error if signature missmatch
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    rm composer-setup.php
    error "Invalid Composer installer signature"
fi

sudo php composer-setup.php --install-dir="$COMPOSER_DIR" --filename=composer
sudo rm composer-setup.php
sudo chmod +x "$COMPOSER_DIR/composer"

# Get installed versions for display
PHP_VERSION=$(php --version | awk '/^PHP/ {print $2}')
COMPOSER_VERSION=$("$COMPOSER_DIR/composer" --version | awk '{print $3}')

success "\e[1mPHP ${PHP_VERSION}\e[0m and \e[1mComposer ${COMPOSER_VERSION}\e[0m have been installed successfully."
