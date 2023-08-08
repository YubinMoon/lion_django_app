from django.contrib import admin
from django.urls import path, include

from . import views

urlpatterns = [
    path("create/", views.create_blog),
    path("update/", views.update_blog),
    path("delete/", views.delete_blog),
    path("read/", views.read_blog),
]
