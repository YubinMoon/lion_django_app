import os

from .base import *

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = True

ALLOWED_HOSTS = [
    "stage-lb-18949272-bc597543c04f.kr.lb.naverncp.com",
]

# CSRF_TRUSTED_ORIGINS = [
#     "http://stage-lb-18949272-bc597543c04f.kr.lb.naverncp.com/",
# ] nginx 없음
