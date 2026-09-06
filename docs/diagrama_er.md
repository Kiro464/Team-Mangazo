Diagrama ER (Base de Datos Relacional)

1. Tabla Rol
Maneja estrictamente los permisos y tipos de acceso de la plataforma.

id (PK)

nombre (Varchar) - Valores: 'Admin', 'Auditor', 'Vendedor', 'Comprador Final', 'Comprador de Comercios'.

descripcion (Text)

2. Tabla Usuario
Centraliza la identidad. El cruce entre su rol_id y es_premium determina exactamente qué tipo de los 5 usuarios mencionados es.

id (PK)

rol_id (FK -> Rol.id)

nombre_completo (Varchar)

correo (Varchar, Unique)

password (Varchar)

telefono_whatsapp (Varchar)

es_premium (Boolean) - Diferencia a un "Vendedor" de un "Vendedor Premium", etc.

fecha_registro (DateTime)

3. Tabla Categoria

id (PK)

nombre (Varchar)

4. Tabla Temporada

id (PK)

mes_numero (Integer)

nombre_mes (Varchar)

5. Tabla Producto

id (PK)

vendedor_id (FK -> Usuario.id)

categoria_id (FK -> Categoria.id)

temporada_id (FK -> Temporada.id)

nombre (Varchar)

descripcion (Text)

precio_referencial (Decimal)

imagen_url (Varchar)

youtube_video_id (Varchar, Nullable)

activo (Boolean)

6. Tabla Pedido_WhatsApp (Cabecera del Pedido)
Representa la transacción única entre un comprador y un vendedor.

id (PK)

comprador_id (FK -> Usuario.id)

vendedor_id (FK -> Usuario.id)

fecha_generacion (DateTime)

estado (Varchar)

7. Tabla Detalle_Pedido (Nueva - Resuelve el Carrito Múltiple)
Permite agregar 'n' cantidad de productos distintos a un mismo pedido.

id (PK)

pedido_id (FK -> Pedido_WhatsApp.id)

producto_id (FK -> Producto.id)

cantidad (Integer o Decimal) - Ej. 2 (unidades) o 1.5 (kg).

precio_unitario_aplicado (Decimal) - Congela el precio al momento de pedir, por si el vendedor lo cambia después.

8. Tabla Encuesta_Resena

id (PK)

pedido_id (FK -> Pedido_WhatsApp.id)

calificacion (Integer)

medios_compra (Varchar)

comentario (Text)

fecha_creacion (DateTime)