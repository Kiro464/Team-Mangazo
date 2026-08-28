import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductoService _productoService = ProductoService();
  final TextEditingController _searchController = TextEditingController();

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];
  List<Producto> _ofertasFlash = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    // Escucha cada vez que el usuario teclea algo
    _searchController.addListener(_filtrarProductos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _productosFiltrados = _productos.where((p) {
        // Busca coincidencias en nombre, categoría o nombre del vendedor
        return p.nombre.toLowerCase().contains(query) ||
            p.categoriaNombre.toLowerCase().contains(query) ||
            p.vendedorNombre.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _cargarDatos() async {
    // Ejecutamos ambas peticiones al mismo tiempo para que cargue más rápido
    final resultados = await Future.wait([
      _productoService.getProductos(),
      _productoService.getOfertasFlash(),
    ]);

    setState(() {
      _productos = resultados[0];
      _productosFiltrados = resultados[0];
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por producto, categoría o vendedor...',
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            // --- SECCIÓN: OFERTAS FLASH ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '⚡ Ofertas Flash (Premium)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 262,
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

            if (_productosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No se encontraron productos coincidentes 🔍',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Desactiva su propio scroll para usar el de la página
                shrinkWrap: true, // Se adapta al tamaño del contenido
                itemCount: _productosFiltrados.length, // <-- CAMBIO AQUÍ
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final producto =
                      _productosFiltrados[index]; // <-- CAMBIO AQUÍ
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
            Container(
              height: 100,
              width: double.infinity,
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
                      child: Image.network(producto.imagen!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.categoriaNombre.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // --- NUEVA SECCIÓN DEL VENDEDOR ---
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          producto.vendedorNombre.isEmpty
                              ? 'Vendedor'
                              : producto.vendedorNombre,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // ------------------------------------
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'C\$ ${producto.precioReferencial}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addItem(producto);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${producto.nombre} agregado al carrito 🛒',
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
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
