#!/bin/bash

# 실행 경로 진입
cd /home/lion/lion_django_app/lion_app
# activate venv
if [ -d "venv/Scripts" ]; then
  source /home/lion/lion_django_app/venv/Scripts/activate
else
  source /home/lion/lion_django_app/venv/bin/activate
fi
# gunicon 실행
gunicorn lion_app.wsgi:application --config gunicorn_config.py
