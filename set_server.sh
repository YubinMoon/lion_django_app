#!/bin/bash

# nginx 설치
sudo apt-get update && sudo apt-get install nginx

# nginx 설정
# sudo cat ./lion_app/lion_app/nginx.conf >/etc/nginx/sites-available/django
sudo sh -c "cat > /etc/nginx/sites-available/django <<EOF
server {
  listen 80;
  server_name 223.130.162.53;

  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $Host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
EOF"
sudo ln -s /etc/nginx/sites-available/django /etc/nginx/sites-enabled/django

# nginx 실행
sudo systemctl restart nginx
