from rest_framework import viewsets
from .models import Usuario, Producto, Categoria, Temporada, PedidoWhatsApp, EncuestaResena
from .serializers import (
    UsuarioSerializer, ProductoSerializer, 
    CategoriaSerializer, TemporadaSerializer,
    PedidoWhatsAppSerializer, EncuestaResenaSerializer
)

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer

class CategoriaViewSet(viewsets.ModelViewSet):
    queryset = Categoria.objects.all()
    serializer_class = CategoriaSerializer

class TemporadaViewSet(viewsets.ModelViewSet):
    queryset = Temporada.objects.all()
    serializer_class = TemporadaSerializer

class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer

class PedidoWhatsAppViewSet(viewsets.ModelViewSet):
    queryset = PedidoWhatsApp.objects.all()
    serializer_class = PedidoWhatsAppSerializer

class EncuestaResenaViewSet(viewsets.ModelViewSet):
    queryset = EncuestaResena.objects.all()
    serializer_class = EncuestaResenaSerializer