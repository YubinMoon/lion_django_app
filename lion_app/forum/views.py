from django.shortcuts import get_object_or_404
from rest_framework import viewsets
from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework import status
from django.db.models import Q
from .models import Topic, Post, TopicGroupUser
from .serializer import TopicSerializer, PostSerializer


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
        if topic.is_private:
            qs = TopicGroupUser.objects.filter(
                Q(group=0) | Q(group=1),
                topic=topic,
                user=user,
            )
            if not qs.exists():
                return Response(
                    status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
                )
        posts = Post.objects.filter(topic=topic)
        serializer = PostSerializer(posts, many=True)
        return Response(status=status.HTTP_200_OK, data=serializer.data)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    def create(self, request, *args, **kwargs):
        # Check Group and Topic
        # if the user dosen't have enough permission to wite a post
        # return 403
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)
        if topic.is_private:
            qs = TopicGroupUser.objects.filter(
                Q(group=0) | Q(group=1),
                topic=topic,
                user=user,
            )
            if not qs.exists():
                return Response(
                    status=status.HTTP_401_UNAUTHORIZED, data={"detail": "권한이 없습니다."}
                )
        serializer = PostSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            data["author"] = user
            res = serializer.create(data)
            return Response(
                status=status.HTTP_201_CREATED, data=PostSerializer(res).data
            )
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)
