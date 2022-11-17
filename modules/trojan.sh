#!/usr/bin/env bash

# Module Prerequisites
# $domain must be set
# $password must be set

install_trojan(){
    set +e
    if [[ ! -f /usr/local/bin/trojan-go/trojan-go ]]; then
        VERSION=$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
        ZIPFILE="trojan-go-linux-amd64.zip"
        DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/v$VERSION/$ZIPFILE"
        echo "Downloading Trojan-Go v$VERSION ..."
        curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

        TMPDIR="$(mktemp -d)"
        cd "$TMPDIR"
        unzip "$ZIPFILE"

        mkdir -p /etc/trojan-go #Config here
	    mkdir -p /usr/share/trojan-go #.dat files here

        cp trojan-go /usr/bin/trojan-go #Executable

        cp geosite.dat /usr/share/trojan-go/geosite.dat
	    cp geoip.dat /usr/share/trojan-go/geoip.dat
	    cp geoip-only-cn-private.dat /usr/share/trojan-go/geoip-only-cn-private.dat

        ln -fs /usr/share/trojan-go/geoip.dat /usr/bin/
	    ln -fs /usr/share/trojan-go/geoip-only-cn-private.dat /usr/bin/
	    ln -fs /usr/share/trojan-go/geosite.dat /usr/bin/

        cd ~
    fi

    echo "Creating systemd service..."
    cat > '/etc/systemd/system/trojan-go.service' << EOF
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
LimitNOFILE=infinity
Restart=always
RestartSec=3s
CPUSchedulingPolicy=rr
CPUSchedulingPriority=99

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable trojan

    cat > '/etc/trojan-go/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        "$password"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "sni": "${domain}",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": false,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "x25519",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": true,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": true,
        "fast_open": false,
        "fast_open_qlen": 0
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
    systemctl restart trojan
}