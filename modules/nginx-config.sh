#!/usr/bin/env bash

nginx_config(){
    rm -rf /etc/nginx/sites-available/*
    rm -rf /etc/nginx/sites-enabled/*
    touch /etc/nginx/conf.d/verify.conf
    touch /etc/nginx/conf.d/default.conf

    cat > '/etc/nginx/conf.d/default.conf' << EOF
server {
    #Note that port 443 and SSL handling is done by Trojan-Go. Nginx is just used for Decoy Website serving.
    #Any non-trojan traffic would be redirected here.

    listen 127.0.0.1:81 fastopen=512 default_server so_keepalive=on;
    listen 127.0.0.1:82 http2 fastopen=512 default_server so_keepalive=on;
    server_name $domain _;

    resolver_timeout 10s;
    client_header_timeout 60m;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header Access-Control-Allow-Origin *;

    location /.well-known/acme-challenge/ { #ACME.sh For certificate issuance and renewal
      root /usr/share/nginx/;
    }

    error_page 497  https://$host$uri?$args;

EOF
    if [[ $install_sample_html == 1 ]]; then
        echo "    location / {" >> /etc/nginx/conf.d/default.conf
        echo "      root /usr/share/nginx/sample/;" >> /etc/nginx/conf.d/default.conf
        echo "    }" >> /etc/nginx/conf.d/default.conf
    fi

    if [[ $install_hexo == 1 ]]; then
        echo "    location / {" >> /etc/nginx/conf.d/default.conf
        echo "      #proxy_pass http://127.0.0.1:4000/; # Hexo server" >> /etc/nginx/conf.d/default.conf
        echo "      root /usr/share/nginx/hexo/public/; # Hexo public content" >> /etc/nginx/conf.d/default.conf
        echo "      #error_page 404  /404.html;" >> /etc/nginx/conf.d/default.conf
        echo "    }" >> /etc/nginx/conf.d/default.conf
    fi

    if [[ $install_alist == 1 ]]; then
        echo "    location / {" >> /etc/nginx/conf.d/default.conf
        echo "      #access_log off;" >> /etc/nginx/conf.d/default.conf
        echo "      client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
        echo "      proxy_set_header X-Forwarded-Proto https;" >> /etc/nginx/conf.d/default.conf
        echo "      proxy_pass http://127.0.0.1:5244/;" >> /etc/nginx/conf.d/default.conf
        echo "      proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
        echo "      proxy_set_header Connection \$http_connection;" >> /etc/nginx/conf.d/default.conf
        echo "    }" >> /etc/nginx/conf.d/default.conf
    fi

    #End of 81 and 82 ports
    echo "" >> /etc/nginx/conf.d/default.conf
    echo "}" >> /etc/nginx/conf.d/default.conf
    echo "" >> /etc/nginx/conf.d/default.conf

    #Handle Port 80 (must redirect to 443)
    echo "server {" >> /etc/nginx/conf.d/default.conf
    echo "    listen 80 fastopen=512 reuseport;" >> /etc/nginx/conf.d/default.conf
    echo "    listen [::]:80 fastopen=512 reuseport;" >> /etc/nginx/conf.d/default.conf
    echo "    location /.well-known/acme-challenge/ {" >> /etc/nginx/conf.d/default.conf
    echo "      root /usr/share/nginx/;" >> /etc/nginx/conf.d/default.conf
    echo "    }" >> /etc/nginx/conf.d/default.conf
    echo "    location / {" >> /etc/nginx/conf.d/default.conf
    echo "      return 301 https://\$host\$request_uri;" >> /etc/nginx/conf.d/default.conf
    echo "    }" >> /etc/nginx/conf.d/default.conf
    echo "}" >> /etc/nginx/conf.d/default.conf

    chown -R nginx:nginx /usr/share/nginx/
    systemctl restart nginx
}