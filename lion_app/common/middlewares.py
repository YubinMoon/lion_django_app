from django.http import JsonResponse
from django.conf import settings


class HttpRefererMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path == "/health/":
            return JsonResponse({"status": "OK"})
        return self.get_response(request)
