from django.db import models
from django.contrib.auth.models import AbstractUser

# 1. Tabla Rol
class Rol(models.Model):
    nombre = models.CharField(max_length=50, unique=True)
    descripcion = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.nombre

# 2. Tabla Usuario (Hereda de AbstractUser para JWT y Auth nativo)
class Usuario(AbstractUser):
    rol = models.ForeignKey(Rol, on_delete=models.SET_NULL, null=True, blank=True)
    telefono_whatsapp = models.CharField(max_length=20, blank=True, null=True)
    es_premium = models.BooleanField(default=False)
    # AbstractUser ya incluye por defecto: id, username, password, email, first_name, last_name, date_joined

    def __str__(self):
        return f"{self.username} - {self.rol.nombre if self.rol else 'Sin Rol'}"

# 3. Tabla Categoria
class Categoria(models.Model):
    nombre = models.CharField(max_length=100)

    def __str__(self):
        return self.nombre

# 4. Tabla Temporada
class Temporada(models.Model):
    mes_numero = models.IntegerField()
    nombre_mes = models.CharField(max_length=20)

    def __str__(self):
        return self.nombre_mes

# 5. Tabla Producto
class Producto(models.Model):
    vendedor = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='productos')
    categoria = models.ForeignKey(Categoria, on_delete=models.SET_NULL, null=True)
    nombre = models.CharField(max_length=150)
    descripcion = models.TextField()
    precio_referencial = models.DecimalField(max_digits=10, decimal_places=2)
    imagen_url = models.URLField(max_length=500, blank=True, null=True)
    youtube_video_id = models.CharField(max_length=50, blank=True, null=True)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre

# 6. Tabla Puente Producto_Temporada
class ProductoTemporada(models.Model):
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    temporada = models.ForeignKey(Temporada, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('producto', 'temporada') # Evita duplicados exactos

# 7. Tabla Pedido_WhatsApp (Cabecera)
class PedidoWhatsApp(models.Model):
    ESTADOS = [
        ('Pendiente', 'Pendiente'),
        ('Completado', 'Completado'),
        ('Cancelado', 'Cancelado'),
    ]
    comprador = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='compras')
    vendedor = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='ventas')
    fecha_generacion = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, choices=ESTADOS, default='Pendiente')

# 8. Tabla Detalle_Pedido (Carrito Múltiple)
class DetallePedido(models.Model):
    pedido = models.ForeignKey(PedidoWhatsApp, on_delete=models.CASCADE, related_name='detalles')
    producto = models.ForeignKey(Producto, on_delete=models.SET_NULL, null=True)
    cantidad = models.DecimalField(max_digits=10, decimal_places=2) # Decimal por si compran kilos (ej. 1.5 kg)
    precio_unitario_aplicado = models.DecimalField(max_digits=10, decimal_places=2)

# 9. Tabla Encuesta_Resena
class EncuestaResena(models.Model):
    pedido = models.OneToOneField(PedidoWhatsApp, on_delete=models.CASCADE) # OneToOne porque es 1 reseña por pedido
    calificacion = models.IntegerField()
    medios_compra = models.CharField(max_length=100)
    comentario = models.TextField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)