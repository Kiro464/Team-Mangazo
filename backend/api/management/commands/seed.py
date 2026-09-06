from django.core.management.base import BaseCommand
from api.models import Rol, Usuario, Categoria, Temporada, Producto, ProductoTemporada

class Command(BaseCommand):
    help = 'Puebla la base de datos con datos de prueba para el Hackaton'

    def handle(self, *args, **kwargs):
        self.stdout.write('Iniciando el poblado de la base de datos...')

        # 1. Crear Roles
        roles_data = ['Admin', 'Vendedor', 'Comprador Final', 'Comprador de Comercios']
        roles_dict = {}
        for r_name in roles_data:
            rol, _ = Rol.objects.get_or_create(nombre=r_name, defaults={'descripcion': f'Rol de {r_name}'})
            roles_dict[r_name] = rol
        self.stdout.write('- Roles creados.')

        # 2. Crear Categorías
        cats_data = ['Frutas', 'Verduras', 'Hortalizas', 'Especias']
        cats_dict = {}
        for c_name in cats_data:
            cat, _ = Categoria.objects.get_or_create(nombre=c_name)
            cats_dict[c_name] = cat
        self.stdout.write('- Categorías creadas.')

        # 3. Crear Temporadas (Meses)
        meses = [(1, 'Enero'), (2, 'Febrero'), (3, 'Marzo'), (4, 'Abril'), (5, 'Mayo'), (6, 'Junio'),
                 (7, 'Julio'), (8, 'Agosto'), (9, 'Septiembre'), (10, 'Octubre'), (11, 'Noviembre'), (12, 'Diciembre')]
        temps_dict = {}
        for num, mes in meses:
            temp, _ = Temporada.objects.get_or_create(mes_numero=num, defaults={'nombre_mes': mes})
            temps_dict[num] = temp
        self.stdout.write('- Temporadas creadas.')

        # 4. Crear Usuarios (Vendedores y Compradores)
        # Vendedor Premium
        if not Usuario.objects.filter(username='don_pepe').exists():
            vendedor1 = Usuario.objects.create_user(
                username='don_pepe', email='pepe@finca.com', password='hackatonpassword',
                first_name='Pepe', last_name='García', rol=roles_dict['Vendedor'], es_premium=True,
                telefono_whatsapp='+50588887777', historia_vendedor='Llevo 20 años cultivando las mejores frutas de la región.'
            )
        else:
            vendedor1 = Usuario.objects.get(username='don_pepe')

        # Vendedor Normal
        if not Usuario.objects.filter(username='maria_huerta').exists():
            vendedor2 = Usuario.objects.create_user(
                username='maria_huerta', email='maria@huerta.com', password='hackatonpassword',
                first_name='María', last_name='López', rol=roles_dict['Vendedor'], es_premium=False,
                telefono_whatsapp='+50577778888', historia_vendedor='Agricultura 100% orgánica y familiar.'
            )
        else:
            vendedor2 = Usuario.objects.get(username='maria_huerta')

        # Comprador
        if not Usuario.objects.filter(username='juan_compras').exists():
            Usuario.objects.create_user(
                username='juan_compras', email='juan@compras.com', password='hackatonpassword',
                first_name='Juan', last_name='Pérez', rol=roles_dict['Comprador Final'], telefono_whatsapp='+50555554444'
            )
        self.stdout.write('- Usuarios creados (Contraseña para todos: hackatonpassword).')

        # 5. Crear Productos y asignarlos a temporadas múltiples
        if not Producto.objects.exists():
            p1 = Producto.objects.create(
                vendedor=vendedor1, categoria=cats_dict['Frutas'], nombre='Sandía Híbrida Premium',
                descripcion='Sandía gigante, muy dulce y refrescante.', precio_referencial=120.00, activo=True
            )
            # Temporada de la Sandía: Julio y Agosto
            ProductoTemporada.objects.create(producto=p1, temporada=temps_dict[7])
            ProductoTemporada.objects.create(producto=p1, temporada=temps_dict[8])

            p2 = Producto.objects.create(
                vendedor=vendedor2, categoria=cats_dict['Verduras'], nombre='Tomate Cherry Orgánico',
                descripcion='Directo de la huerta a tu mesa. Sin pesticidas.', precio_referencial=45.50, activo=True
            )
            # Temporada del Tomate Cherry: Todo el año (agregamos un par de meses de ejemplo)
            ProductoTemporada.objects.create(producto=p2, temporada=temps_dict[1])
            ProductoTemporada.objects.create(producto=p2, temporada=temps_dict[2])
            ProductoTemporada.objects.create(producto=p2, temporada=temps_dict[3])
            self.stdout.write('- Productos y relaciones de temporadas creadas.')

        self.stdout.write(self.style.SUCCESS('¡Base de datos poblada con éxito!'))