from django.db import models
from django.contrib.auth.models import User


# Create your models here.
class Topic(models.Model):
    name = models.TextField(unique=True)
    is_private = models.BooleanField(default=False)
    owner = models.ForeignKey(User, on_delete=models.PROTECT)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    posts: models.QuerySet["Post"]

    def __str__(self):
        return self.name


class Post(models.Model):
    topic = models.ForeignKey(Topic, on_delete=models.CASCADE, related_name="posts")
    title = models.TextField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} by {self.author}"


class TopicGroupUser(models.Model):
    class GroupChoices(models.IntegerChoices):
        COMMON = 0
        ADMIN = 1

    topic = models.ForeignKey(Topic, on_delete=models.CASCADE)
    group = models.IntegerField(default=0, choices=GroupChoices.choices)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
