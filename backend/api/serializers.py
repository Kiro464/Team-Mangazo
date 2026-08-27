from rest_framework import serializers
from .models import Usuario, Rol, Categoria, Temporada, Producto, DetallePedido, PedidoWhatsApp, EncuestaResena

class RolSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rol
        fields = '__all__'

class UsuarioSerializer(serializers.ModelSerializer):
    # Añadimos el campo password explícitamente para el registro
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'password', 'first_name', 'last_name', 
                  'telefono_whatsapp', 'es_premium', 'rol', 
                  'foto_perfil', 'historia_vendedor', 'link_redes']

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
    # Esto es para ENVIAR los detalles a Flutter (Lectura)
    detalles = DetallePedidoSerializer(many=True, read_only=True)
    
    # Esto es para RECIBIR el carrito desde Flutter (Escritura)
    detalles_creacion = serializers.ListField(
        child=serializers.DictField(), write_only=True
    )

    class Meta:
        model = PedidoWhatsApp
        fields = ['id', 'comprador', 'vendedor', 'fecha_generacion', 'estado', 'detalles', 'detalles_creacion']

    # Sobrescribimos el método create para manejar el carrito con múltiples productos
    def create(self, validated_data):
        detalles_data = validated_data.pop('detalles_creacion')
        pedido = PedidoWhatsApp.objects.create(**validated_data)
        
        # Guardamos cada producto del carrito en la tabla Detalle_Pedido
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