import os
from pymongo import MongoClient
from django.http import HttpResponse, JsonResponse

client = MongoClient(
    host=os.getenv("MONGO_HOST", "localhost"),
)
db = client.likelion


def create_blog(request) -> bool:
    blog = {
        "title": "My First Blog",
        "content": "This is my first blog post",
        "author": "Lion",
    }
    try:
        db.blogs.insert_one(blog)
        return JsonResponse({"status": True})
    except Exception as e:
        print(e)
        return JsonResponse({"status": False})


def update_blog():
    ...


def delete_blog():
    ...


def read_blog():
    ...
