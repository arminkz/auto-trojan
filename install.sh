#!/usr/bin/env bash

set +e

if [[ $(id -u) != 0 ]]; then
  echo -e "Please run this script as root or sudoer."
  exit 1
fi


check_install() {

}

install_base() {
    apt-get update
    colorEcho ${INFO} "Installing all necessary software..."
    apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release unzip resolvconf ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less neofetch -y
    apt-get install bc -y
    sh -c 'echo "y\n\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get install ntp -q -y'
}



