from rest_framework import serializers
from .models import Usuario, Rol, Categoria, Temporada, Producto, DetallePedido, PedidoWhatsApp, EncuestaResena
from django.db.models import Avg

class RolSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rol
        fields = '__all__'

class UsuarioSerializer(serializers.ModelSerializer):
    # Añadimos el campo password explícitamente para el registro
    password = serializers.CharField(write_only=True)

    # Campos calculados dinámicamente para el perfil público
    promedio_calificaciones = serializers.SerializerMethodField()
    resenas = serializers.SerializerMethodField()

    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'password', 'first_name', 'last_name', 
                  'telefono_whatsapp', 'es_premium', 'rol', 
                  'foto_perfil', 'historia_vendedor', 'link_redes', 'video_youtube',
                  'promedio_calificaciones', 'resenas']

    def get_promedio_calificaciones(self, obj):
        # Calcula el promedio de las reseñas conectadas a pedidos de este vendedor
        resenas = EncuestaResena.objects.filter(pedido__vendedor=obj, calificacion__gt=0)
        if resenas.exists():
            return round(resenas.aggregate(Avg('calificacion'))['calificacion__avg'], 1)
        return 0.0

    def get_resenas(self, obj):
        # Obtiene las últimas 10 reseñas del vendedor
        resenas = EncuestaResena.objects.filter(pedido__vendedor=obj).order_by('-id')[:10]
        return ResenaVendedorSerializer(resenas, many=True).data

    # Sobrescribimos el método create para encriptar la contraseña
    def create(self, validated_data):
        usuario = Usuario(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            telefono_whatsapp=validated_data.get('telefono_whatsapp', ''),
            rol=validated_data.get('rol')
        )
        # set_password es la función nativa de Django que aplica la encriptación
        usuario.set_password(validated_data['password'])
        usuario.save()
        return usuario

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
    # Extraemos el nombre completo del vendedor (first_name + last_name)
    vendedor_nombre = serializers.ReadOnlyField(source='vendedor.get_full_name')
    # Añadimos el ID y el teléfono del vendedor para el Carrito y el filtrado
    vendedor_id = serializers.ReadOnlyField(source='vendedor.id')
    vendedor_telefono = serializers.ReadOnlyField(source='vendedor.telefono_whatsapp')
    
    class Meta:
        model = Producto
        fields = '__all__'

class DetallePedidoSerializer(serializers.ModelSerializer):
    # Campo extra para que Flutter reciba el nombre del producto fácilmente
    producto_nombre = serializers.ReadOnlyField(source='producto.nombre')

    class Meta:
        model = DetallePedido
        fields = ['id', 'producto', 'producto_nombre', 'cantidad', 'precio_unitario_aplicado']

class PedidoWhatsAppSerializer(serializers.ModelSerializer):
    detalles = DetallePedidoSerializer(many=True, read_only=True)
    detalles_creacion = serializers.ListField(child=serializers.DictField(), write_only=True)
    vendedor_nombre = serializers.SerializerMethodField()
    # 1. Hacemos que el comprador sea de solo lectura (Django lo asignará)
    comprador = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = PedidoWhatsApp
        fields = ['id', 'comprador', 'vendedor', 'vendedor_nombre', 'fecha_generacion', 'estado', 'detalles', 'detalles_creacion']

    def get_vendedor_nombre(self, obj):
        nombre = obj.vendedor.get_full_name()
        return nombre if nombre.strip() else obj.vendedor.username

    def create(self, validated_data):
        detalles_data = validated_data.pop('detalles_creacion')
        
        # 2. Asignamos al comprador mágicamente usando el Token JWT del request
        validated_data['comprador'] = self.context['request'].user
        
        pedido = PedidoWhatsApp.objects.create(**validated_data)
        
        for detalle in detalles_data:
            DetallePedido.objects.create(
                pedido=pedido,
                producto_id=detalle['producto_id'],
                cantidad=detalle['cantidad'],
                precio_unitario_aplicado=detalle['precio_unitario_aplicado']
            )
        return pedido

class EncuestaResenaSerializer(serializers.ModelSerializer):
    class Meta:
        model = EncuestaResena
        fields = '__all__'

class ResenaVendedorSerializer(serializers.ModelSerializer):
    # Extraemos el nombre de quien compró y la fecha del pedido
    comprador_nombre = serializers.ReadOnlyField(source='pedido.comprador.get_full_name')
    fecha = serializers.ReadOnlyField(source='pedido.fecha_generacion')
    
    class Meta:
        model = EncuestaResena
        fields = ['calificacion', 'comentario', 'comprador_nombre', 'fecha']

