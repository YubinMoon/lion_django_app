from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
)
from django.conf import settings
from django.conf.urls.static import static

from blog.urls import router as blog_router
from forum.urls import router as forum_router
from .health import health_check
from .version import version

urlpatterns = [
    path("version/", version),
    path("admin/", admin.site.urls),
    path("blog/", include(blog_router.urls)),
    path("forum/", include(forum_router.urls)),
    path("api-auth/", include("rest_framework.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    # Optional UI:
    path(
        "api/docs/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
