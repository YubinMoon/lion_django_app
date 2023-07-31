#!/bin/bash

# git clone
git clone https://github.com/YubinMoon/lion_django_app.git lion_django_app
cd lion_django_app

# venv 설치
sudo apt-get update && sudo apt install -y python3-venv

# venv 구성
python -m venv venv

# 가상환경 작동
if [ -d "venv/Scripts" ]; then
  source venv/Scripts/activate
else
  source venv/bin/activate
fi

# pip install
pip install -r requirements.txt

# runserver
cd lion_app
python manage.py runserver 0.0.0.0:8000
