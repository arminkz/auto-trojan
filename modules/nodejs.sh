set +e

install_nodejs(){
    if [[ ${dist} == debian ]]; then
        curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
    elif [[ ${dist} == ubuntu ]]; then
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    else
        color_echo ${ERROR} "Only Ubuntu & Debian is supported."
        exit 1
    fi
    apt-get update
    apt-get install -y nodejs
}