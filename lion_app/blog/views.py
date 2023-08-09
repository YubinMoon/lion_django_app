import os

from django.http import JsonResponse
from pymongo import MongoClient
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet
from rest_framework import status

from .serializer import BlogSerializer


class BlogViewSet(ViewSet):
    serializer_class = BlogSerializer

    def list(self, request):
        return Response(status=status.HTTP_200_OK)

    def create(self, request):
        serializer = BlogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.create(serializer.validated_data)
            return Response(status=status.HTTP_201_CREATED, data=serializer.data)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

    def update(self, request, pk=None):
        ...

    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

    def destroy(self, request, pk=None):
        ...
