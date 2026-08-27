from rest_framework import serializers
from .models import Usuario, Rol, Categoria, Temporada, Producto

class RolSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rol
        fields = '__all__'

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        # Excluimos el password y datos sensibles por seguridad en la API
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'telefono_whatsapp', 'es_premium', 'rol']

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = '__all__'

class TemporadaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Temporada
        fields = '__all__'

class ProductoSerializer(serializers.ModelSerializer):
    # Campo de solo lectura para facilitar el trabajo en Flutter
    categoria_nombre = serializers.ReadOnlyField(source='categoria.nombre')
    
    class Meta:
        model = Producto
        fields = '__all__'