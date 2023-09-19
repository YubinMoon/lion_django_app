from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(["GET"])
def version(request):
    return Response(status=status.HTTP_200_OK, data={"version": "0.1.2"})
