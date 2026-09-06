# Icidro - Hackathon Nicaragua 2026

Icidro es una plataforma de comercio electrónico bidireccional (Marketplace) que conecta directamente a productores y vendedores locales con compradores. Diseñada con una arquitectura Cliente-Servidor robusta, Icidro optimiza la logística de pedidos, visibilidad de catálogos y ofrece una experiencia de usuario personalizada según el rol (Comprador o Vendedor).

## Tecnologías Utilizadas

*   **Frontend:** Flutter (Dart) con gestión de estado vía `Provider`.
*   **Backend:** Python 3 + Django + Django REST Framework.
*   **Autenticación:** JSON Web Tokens (JWT) con rotación configurada.
*   **Base de Datos:** SQLite (Desarrollo) / PostgreSQL (Producción).
*   **Control de Versiones:** Git / GitHub.

## Funcionalidades Principales

*   **Sistema de Roles:** Interfaz adaptativa (Verde para compradores, Ámbar para vendedores).
*   **Gestión de Catálogo:** Creación y edición de productos, control de visibilidad (Activo/Inactivo), gestión de temporadas y "Ofertas Flash".
*   **Flujo de Pedidos Completo:** Carrito de compras persistente, creación de órdenes y gestión de estados (Pendiente, Aceptado, Cancelado, Completado).
*   **Sistema Premium:** Algoritmo de priorización en catálogos y perfiles verificados (Comercios y Usuarios Premium).
*   **Perfiles Públicos:** Vendedores con biografía, contacto directo (WhatsApp) y enlaces a redes/YouTube.

## Requisitos Previos

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 o superior)
*   [Python](https://www.python.org/downloads/) (v3.10 o superior)
*   Dispositivos físicos (Android/iOS) o Emulador conectados a la misma red local.

## 🛠️ Instalación y Ejecución en Desarrollo (Local)

Para ejecutar la plataforma en una red local y testear con dispositivos físicos simultáneos:

### 1. Despliegue del Backend (Django)
```bash
# 1. Navegar a la carpeta del backend
cd backend

# 2. Crear y activar entorno virtual
python -m venv venv
# En Windows: venv\Scripts\activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Aplicar migraciones a la base de datos
python manage.py migrate

# 5. Ejecutar servidor abierto a la red local
python manage.py runserver 0.0.0.0:8000