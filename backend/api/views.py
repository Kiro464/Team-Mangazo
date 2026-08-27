from rest_framework import viewsets
from .models import Usuario, Producto, Categoria, Temporada, PedidoWhatsApp, EncuestaResena
from .serializers import (
    UsuarioSerializer, ProductoSerializer, 
    CategoriaSerializer, TemporadaSerializer,
    PedidoWhatsAppSerializer, EncuestaResenaSerializer
)
from rest_framework.decorators import action
from rest_framework.response import Response
import datetime

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

    # 1. Algoritmo de Ofertas Flash
    @action(detail=False, methods=['get'], url_path='ofertas-flash')
    def ofertas_flash(self, request):
        # Filtramos solo activos. 
        # El signo negativo en '-vendedor__es_premium' hace un orden descendente (True primero, False después).
        # Luego ordenamos por precio más bajo. Limitamos a los 10 mejores resultados.
        ofertas = Producto.objects.filter(activo=True).order_by('-vendedor__es_premium', 'precio_referencial')[:10]
        
        # Traducimos de base de datos a JSON
        serializer = self.get_serializer(ofertas, many=True)
        return Response(serializer.data)

    # 2. Algoritmo de Calendario de Temporada
    @action(detail=False, methods=['get'], url_path='calendario-temporada')
    def calendario_temporada(self, request):
        # Obtenemos el mes actual (del 1 al 12) desde el servidor
        mes_actual = datetime.datetime.now().month
        
        # Filtramos productos cruzando la tabla puente (ProductoTemporada) hasta encontrar el mes
        # Usamos distinct() porque si un producto por error tiene el mismo mes dos veces, no queremos duplicados
        productos_mes = Producto.objects.filter(
            activo=True,
            productotemporada__temporada__mes_numero=mes_actual
        ).distinct()
        
        serializer = self.get_serializer(productos_mes, many=True)
        return Response(serializer.data)

class PedidoWhatsAppViewSet(viewsets.ModelViewSet):
    queryset = PedidoWhatsApp.objects.all()
    serializer_class = PedidoWhatsAppSerializer

class EncuestaResenaViewSet(viewsets.ModelViewSet):
    queryset = EncuestaResena.objects.all()
    serializer_class = EncuestaResenaSerializer