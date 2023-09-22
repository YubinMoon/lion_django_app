from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(["GET"])
def user(request):
    data = {
        "pk": request.user.pk,
        "username": request.user.username,
    }
    return Response(status=status.HTTP_200_OK, data=data)
