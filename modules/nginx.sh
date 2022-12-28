#!/usr/bin/env bash

#required envs: $dist

install_nginx() {
    set +e
    echo "Installing nginx dependencies..."
    apt-get install ca-certificates lsb-release -y -q
    apt-get install gnupg gnupg2 -y -q
    echo "Adding nginx repository..."
    touch /etc/apt/sources.list.d/nginx.list
    if [[ ${dist} == ubuntu ]]; then
        echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx"  | sudo tee /etc/apt/sources.list.d/nginx.list
    else
        tee -a /etc/apt/sources.list.d/nginx.list > /dev/null <<EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
    fi
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-get update
    sh -c 'echo "y\n\ny\ny\ny\n" | apt-get install nginx -y'
    id -u nginx
    if [[ $? != 0 ]]; then
        useradd -r nginx --shell=/usr/sbin/nologin
        apt-get install nginx -y
    fi

    # Modify Nginx service definition
    cat > '/lib/systemd/system/nginx.service' << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
Before=netdata.service trojan.service
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
LimitNOFILE=infinity
Restart=always
RestartSec=3s
CPUSchedulingPolicy=rr
CPUSchedulingPriority=98

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable nginx
    mkdir /usr/share/nginx/cache &> /dev/null

    cat > '/etc/nginx/nginx.conf' << EOF
user root;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 100000;
  worker_aio_requests 1024;
  use epoll;
  multi_accept on;
}

http {
  autoindex_exact_size off;
  http2_push_preload on;
  aio threads;
  aio_write on;
  charset UTF-8;
  tcp_nodelay on;
  tcp_nopush on;
  server_tokens off;
  
  proxy_intercept_errors off;
  proxy_http_version 1.1;
  proxy_ssl_protocols TLSv1.2 TLSv1.3;
  proxy_set_header Host \$http_host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
  proxy_socket_keepalive on;
  proxy_max_temp_file_size 0;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_cf_connecting_ip" "\$http_x_forwarded_for" "\$gzip_ratio"';
  access_log /var/log/nginx/access.log main;
  sendfile on;
  gzip on;
  gzip_proxied any;
  gzip_types
    application/javascript
    application/x-javascript
    text/javascript
    text/css
    text/xml
    application/xhtml+xml
    application/xml
    application/atom+xml
    application/rdf+xml
    application/rss+xml
    application/geo+json
    application/json
    application/ld+json
    application/manifest+json
    application/x-web-app-manifest+json
    image/svg+xml
    text/x-cross-domain-policy;
  gzip_comp_level 1;
  gzip_vary on;
  gzip_static on;
  gzip_disable "MSIE [1-6]\.";  
  include /etc/nginx/conf.d/default.conf;
  include /etc/nginx/conf.d/verify.conf;
}
EOF
    touch /etc/nginx/conf.d/verify.conf
    touch /etc/nginx/conf.d/default.conf
    systemctl restart nginx
}