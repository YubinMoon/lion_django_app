import json
import tempfile
import io
from unittest.mock import MagicMock, patch
from PIL import Image
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
        cls.common_post = Post.objects.create(
            title="common post",
            content="common post",
            topic=cls.private_topic,
            author=cls.common_user,
        )
        cls.admin_post = Post.objects.create(
            title="admin post",
            content="admin post",
            topic=cls.private_topic,
            author=cls.admin_user,
        )

        cls.data = {
            "title": "test title",
            "content": "test content",
            "topic": cls.private_topic.pk,
        }

    def generate_photo_file(self):
        file = io.BytesIO()
        image = Image.new("RGBA", size=(100, 100), color=(155, 0, 0))
        image.save(file, "png")
        file.name = "test.png"
        file.seek(0)
        return file

    def test_write_permission_on_private_topic(self):
        # when unauthorized user tries to write a post on tocis => fail. 401
        data = self.data.copy()
        self.client.force_login(self.unauthorized_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # when common group user tries to write a post on topics => success. 201
        data = self.data.copy()
        self.client.force_login(self.common_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        self.assertEqual(len(data["image_url"]), 0)
        Post.objects.get(pk=data["id"])

        # when admin group user tries to write a post on topics => success. 201
        data = self.data.copy()
        self.client.force_login(self.admin_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        self.assertEqual(len(data["image_url"]), 0)
        Post.objects.get(pk=data["id"])

        # when owner user tries to write a post on topics => success. 201
        data = self.data.copy()
        self.client.force_login(self.topic_owner)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        self.assertEqual(len(data["image_url"]), 0)
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

        # for common user => success. 200
        self.client.force_login(self.common_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)

        # for admin user => success. 200
        self.client.force_login(self.admin_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)

        # for owner user => success. 200
        self.client.force_login(self.topic_owner)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)

    def test_read_permission_on_posts(self):
        # read public post
        self.client.force_login(self.unauthorized_user)
        public_posts = Post.objects.filter(topic=self.public_topic)
        for post in public_posts:
            res = self.client.get(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        # read private post
        private_posts = Post.objects.filter(topic=self.private_topic)
        # for unauthorized user => fail. 401
        self.client.force_login(self.unauthorized_user)
        for post in private_posts:
            res = self.client.get(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # for common user => success. 200
        self.client.force_login(self.common_user)
        for post in private_posts:
            res = self.client.get(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        # for admin user => success. 200
        self.client.force_login(self.admin_user)
        for post in private_posts:
            res = self.client.get(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

        # for owner user => success. 200
        self.client.force_login(self.topic_owner)
        for post in private_posts:
            res = self.client.get(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_200_OK)

    @patch("forum.views.boto3.client")
    def test_post_with_or_without_image(self, client: MagicMock):
        # magic mock
        s3 = MagicMock()
        client.return_value = s3
        s3.upload_fileobj.return_value = None
        s3.put_object_acl.return_value = None

        # without image => success.
        data = self.data.copy()
        self.client.force_login(self.common_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        self.assertEqual(len(data["image_url"]), 0)

        # with image => success.
        data = self.data.copy()
        data["image"] = self.generate_photo_file()
        self.client.force_login(self.common_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        self.assertGreater(len(data["image_url"]), 0)
        Post.objects.get(pk=data["id"])

        s3.upload_fileobj.assert_called_once()
        s3.put_object_acl.assert_called_once()

    def test_delete_permission(self):
        # unauthorized delete common post > fail
        self.client.force_login(self.unauthorized_user)
        res = self.client.delete(reverse("post-detail", args=[self.common_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # common delete admin post > fail
        self.client.force_login(self.common_user)
        res = self.client.delete(reverse("post-detail", args=[self.admin_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # common delete common post > success
        self.client.force_login(self.common_user)
        res = self.client.delete(reverse("post-detail", args=[self.common_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # admin delete admin post > success
        self.client.force_login(self.admin_user)
        res = self.client.delete(reverse("post-detail", args=[self.admin_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # owner delete any post > success
        self.client.force_login(self.topic_owner)
        posts = Post.objects.filter(topic=self.private_topic).all()
        for post in posts:
            res = self.client.delete(reverse("post-detail", args=[post.pk]))
            self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # owner can delete any post
        # admin can delete any post
        # common can delete only his/her post
        # unauthorized can't delete any post
