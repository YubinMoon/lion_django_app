import boto3
import uuid
import os
from django.shortcuts import get_object_or_404
from django.core.files.uploadedfile import InMemoryUploadedFile
from rest_framework import viewsets
from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework import status, mixins
from django.db.models import Q
from .models import Topic, Post, TopicGroupUser
from .serializer import TopicSerializer, PostSerializer, PostCreateSerializer


@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer

    @extend_schema(summary="새 토픽 생성")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)

    @action(detail=True, methods=["GET"], url_name="posts")
    def posts(self, request, *args, **kwargs):
        user = request.user
        topic: Topic = self.get_object()
        if not topic.can_be_read_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
            )
        posts = topic.posts
        serializer = PostSerializer(posts, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    @extend_schema(deprecated=True)
    def list(self, request, *args, **kwargs):
        return Response(status=status.HTTP_400_BAD_REQUEST, data="Deprecated API")

    def get_serializer_class(self):
        if self.action == "create":
            return PostCreateSerializer
        return super().get_serializer_class()

    def create(self, request, *args, **kwargs):
        # Check Group and Topic
        # if the user dosen't have enough permission to wite a post
        # return 403
        url = ""
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)
        if not topic.can_be_read_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
            )

        # Check if file exists
        file: InMemoryUploadedFile = data.get("image")
        if file:
            # connect to boto3
            service_name = "s3"
            endpoint_url = "https://kr.object.ncloudstorage.com"
            access_key = os.getenv("NCP_ACCESS_KEY")
            secret_key = os.getenv("NCP_SECRET_KEY")
            s3 = boto3.client(
                service_name,
                endpoint_url=endpoint_url,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
            )
            bucket_name = "lime-image"
            image_id = f"{str(uuid.uuid4())}.{file.name.split('.')[-1]}"
            s3.upload_fileobj(file.file, bucket_name, image_id)
            s3.put_object_acl(Bucket=bucket_name, Key=image_id, ACL="public-read")
            url = f"{endpoint_url}/{bucket_name}/{image_id}"
        serializer = PostSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            data["author"] = user
            data["image_url"] = url
            res = serializer.create(data)
            return Response(
                status=status.HTTP_201_CREATED, data=PostSerializer(res).data
            )
        return Response(status=status.HTTP_200_OK, data="asdf")
        # else:
        #     return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

    def retrieve(self, request, *args, pk=None, **kwargs):
        user = request.user
        post = get_object_or_404(Post, id=pk)
        topic = post.topic
        if not topic.can_be_read_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
            )
        return super().retrieve(request, *args, **kwargs)

    def destroy(self, request, *args, pk=None, **kwargs):
        user = request.user
        post = get_object_or_404(Post, id=pk)
        topic = post.topic
        if (
            user == post.author
            or user == topic.owner
            or TopicGroupUser.objects.filter(
                user=user, topic=topic, group=TopicGroupUser.GroupChoices.ADMIN
            ).exists()
        ):
            return super().destroy(request, *args, **kwargs)
        return Response(
            status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
        )
