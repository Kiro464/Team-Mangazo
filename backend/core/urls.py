"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

from api.views import UsuarioViewSet, ProductoViewSet, CategoriaViewSet, TemporadaViewSet, PedidoWhatsAppViewSet, EncuestaResenaViewSet

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet)
router.register(r'productos', ProductoViewSet)
router.register(r'categorias', CategoriaViewSet)
router.register(r'temporadas', TemporadaViewSet)
router.register(r'pedidos', PedidoWhatsAppViewSet)
router.register(r'resenas', EncuestaResenaViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),

    # Se integran las rutas de las tablas a la API
    path('api/', include(router.urls)),
    
    # Endpoints para la autenticación JWT
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Endpoints de Documentación (Swagger y Redoc)
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'), # El archivo base
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'), # Interfaz Swagger
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'), # Interfaz Redoc
]
