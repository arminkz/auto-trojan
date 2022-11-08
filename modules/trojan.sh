

install_trojan(){
    set +e
    if [[ ! -f /usr/local/bin/auto-trojan ]]; then
        colorEcho ${INFO} "Installing Trojan-GFW..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
        systemctl daemon-reload
        colorEcho ${INFO} "Configuring Trojan-GFW..."
        setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/trojan
        mv -f /usr/local/bin/trojan /usr/local/bin/auto-trojan
    fi
    cat > '/etc/systemd/system/trojan.service' << EOF
[Unit]
Description=trojan
Documentation=https://trojan-gfw.github.io/trojan/config https://trojan-gfw.github.io/trojan/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
ExecStart=/usr/local/bin/auto-trojan /usr/local/etc/trojan/config.json
ExecReload=/bin/kill -HUP \$MAINPID
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
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "key_password": "",
        "cipher": "${cipher_server}",
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
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
    chmod -R 755 /usr/local/etc/trojan/
    systemctl restart trojan
}