#!/bin/bash

# git pull
git pull

# source
if [ -d "venv/Scripts" ]; then
  source venv/Scripts/activate
else
  source venv/bin/activate
fi

# runserver
cd lion_app
python manage.py runserver 0.0.0.0:8000
