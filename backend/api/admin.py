from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import (
    Usuario, Rol, Categoria, Temporada, 
    Producto, ProductoTemporada, PedidoWhatsApp, 
    DetallePedido, EncuestaResena
)

# 1. Configuración avanzada para Usuario
@admin.register(Usuario)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'rol', 'es_premium', 'is_staff')
    # Añadimos tus campos personalizados al formulario de Django
    fieldsets = UserAdmin.fieldsets + (
        ('Información del Marketplace', {'fields': ('rol', 'telefono_whatsapp', 'es_premium')}),
    )

# 2. Configuración para los Roles
@admin.register(Rol)
class RolAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'descripcion')

# 3. Configuración para Categorías
@admin.register(Categoria)
class CategoriaAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombre')
    search_fields = ('nombre',)

# 4. Configuración para Temporadas
@admin.register(Temporada)
class TemporadaAdmin(admin.ModelAdmin):
    list_display = ('mes_numero', 'nombre_mes')
    ordering = ('mes_numero',) # Ordena los meses del 1 al 12

# 5. Configuración para el Catálogo de Productos
@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'vendedor', 'categoria', 'precio_referencial', 'activo')
    list_filter = ('categoria', 'activo') # Agrega un panel de filtros lateral
    search_fields = ('nombre', 'descripcion')

# 6. Registros simples para el resto de tablas
admin.site.register(ProductoTemporada)
admin.site.register(PedidoWhatsApp)
admin.site.register(DetallePedido)
admin.site.register(EncuestaResena)