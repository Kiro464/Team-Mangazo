import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productos = [];
  List<Producto> _ofertasFlash = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Ejecutamos ambas peticiones al mismo tiempo para que cargue más rápido
    final resultados = await Future.wait([
      _productoService.getProductos(),
      _productoService.getOfertasFlash(),
    ]);

    setState(() {
      _productos = resultados[0];
      _ofertasFlash = resultados[1];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos, // Permite recargar al deslizar hacia abajo
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN: OFERTAS FLASH ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '⚡ Ofertas Flash (Premium)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _ofertasFlash.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final producto = _ofertasFlash[index];
                  return _buildProductoCard(producto, isFlash: true);
                },
              ),
            ),

            // --- SECCIÓN: CATÁLOGO GENERAL ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '🍎 Todo el Catálogo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Desactiva su propio scroll para usar el de la página
              shrinkWrap: true, // Se adapta al tamaño del contenido
              itemCount: _productos.length,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemBuilder: (context, index) {
                final producto = _productos[index];
                return _buildProductoCard(producto, isFlash: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para dibujar la tarjeta (card) del producto
  Widget _buildProductoCard(Producto producto, {required bool isFlash}) {
    return Container(
      width: isFlash ? 160 : double.infinity,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            SizedBox(
              height: isFlash ? 90 : 120,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: producto.imagen != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          producto.imagen!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.categoriaNombre.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'C\$ ${producto.precioReferencial}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
