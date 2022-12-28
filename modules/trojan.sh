#!/usr/bin/env bash

# Module Prerequisites
# $domain must be set
# $password must be set

install_trojan(){
    set +e
    if [[ ! -f /usr/bin/trojan-go ]]; then
        VERSION=$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
        ZIPFILE="trojan-go-linux-amd64.zip"
        DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/v$VERSION/$ZIPFILE"
        echo "Downloading Trojan-Go v$VERSION ..."
        curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

        mkdir tmp
        unzip "$ZIPFILE" -d ./tmp

        mkdir -p /etc/trojan-go #Config here
	    mkdir -p /usr/share/trojan-go #.dat files here

        cp ./tmp/trojan-go /usr/bin/trojan-go #Executable

        cp ./tmp/geosite.dat /usr/share/trojan-go/geosite.dat
	    cp ./tmp/geoip.dat /usr/share/trojan-go/geoip.dat
	    cp ./tmp/geoip-only-cn-private.dat /usr/share/trojan-go/geoip-only-cn-private.dat

        ln -fs /usr/share/trojan-go/geoip.dat /usr/bin/
	    ln -fs /usr/share/trojan-go/geoip-only-cn-private.dat /usr/bin/
	    ln -fs /usr/share/trojan-go/geosite.dat /usr/bin/

        rm "$ZIPFILE"
        rm -rf ./tmp
    fi

    echo "Creating systemd service..."
    cat > '/etc/systemd/system/trojan-go.service' << EOF
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target network-online.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/trojan-go -config /etc/trojan-go/config.json
LimitNOFILE=infinity
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable trojan-go

    echo "Creating config file..."
    cat > '/etc/trojan-go/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        "$password"
    ],
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "sni": "${domain}",
        "fallback_addr": "127.0.0.1",
        "fallback_port": 81,
        "fingerprint": "chrome"
    },
    "websocket": {
        "enabled": true,
        "path": "/ws",
        "hostname": "${domain}"
    }
}
EOF
    systemctl restart trojan-go
}

