cat <<EOF > /etc/nginx/conf.d/nginx.conf
server {
        listen 80;
        listen [::]:80;

        server_name $1;

        location / {
                proxy_pass http://$2:80/;
        }
}
EOF

