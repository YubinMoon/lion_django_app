import json
from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from rest_framework import status

from .models import Topic, Post, TopicGroupUser


class PostTest(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.superuser = User.objects.create_superuser("superuser")
        cls.topic_owner = User.objects.create_user("topic_owner")
        cls.private_topic = Topic.objects.create(
            name="private topic",
            is_private=True,
            owner=cls.topic_owner,
        )
        cls.public_topic = Topic.objects.create(
            name="public topic",
            is_private=False,
            owner=cls.superuser,
        )
        for i in range(5):
            Post.objects.create(
                title=f"post {i}",
                content=f"content {i}",
                topic=cls.public_topic,
                author=cls.superuser,
            )
        for i in range(5):
            Post.objects.create(
                title=f"post {i}",
                content=f"content {i}",
                topic=cls.private_topic,
                author=cls.superuser,
            )
        cls.common_user = User.objects.create_user("common_user")
        cls.admin_user = User.objects.create_user("admin_user")
        cls.unauthorized_user = User.objects.create_user("unauthorized")
        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            user=cls.common_user,
            group=TopicGroupUser.GroupChoices.COMMON,
        )
        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            user=cls.admin_user,
            group=TopicGroupUser.GroupChoices.ADMIN,
        )

    def test_write_permission_on_private_topic(self):
        # when unauthorized user tries to write a post on tocis => fail. 401
        data = {
            "title": "test title",
            "content": "test content",
            "topic": self.private_topic.pk,
            "author": self.unauthorized_user.pk,
        }
        self.client.force_login(self.unauthorized_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # when common group user tries to write a post on topics => success. 201
        self.client.force_login(self.common_user)
        data["author"] = self.common_user.pk
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        Post.objects.get(pk=data["id"])

        # when admin group user tries to write a post on topics => success. 201
        self.client.force_login(self.admin_user)
        data["author"] = self.admin_user.pk
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        Post.objects.get(pk=data["id"])

        # when owner user tries to write a post on topics => success. 201
        self.client.force_login(self.topic_owner)
        data["author"] = self.topic_owner.pk
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        Post.objects.get(pk=data["id"])

    def test_read_permission_on_topics(self):
        # read public topic
        self.client.force_login(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.public_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.public_topic).count()
        self.assertEqual(len(data), posts_n)

        # read private topic
        # for unauthorized user => fail. 401
        self.client.force_login(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        # for authorized user => success. 200
        self.client.force_login(self.common_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)
