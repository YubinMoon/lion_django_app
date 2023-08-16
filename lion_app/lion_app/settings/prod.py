import os

from .base import *

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = False

ALLOWED_HOSTS = [
    "lion-lb-18904498-6a890bf84dc5.kr.lb.naverncp.com",
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-lb-18904498-6a890bf84dc5.kr.lb.naverncp.com",
]
