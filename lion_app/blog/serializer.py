import os
from pymongo import MongoClient
from rest_framework import serializers

client = MongoClient(
    host=os.getenv("MONGO_HOST", "localhost"),
)
db = client.likelion


class BlogSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=100)
    content = serializers.CharField()
    author = serializers.CharField(max_length=100)

    def create(self, validated_data):
        db.blogs.insert_one(validated_data)

    def save(self, **kwargs):
        # Find Item
        # If exists
        # update
        # else
        # create
        ...
