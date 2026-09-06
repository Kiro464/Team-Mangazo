import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/cart_provider.dart';
import '../services/vendedor_service.dart'; // <-- Importamos el servicio de vendedores
import 'vendedor_detail_screen.dart';

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
  List<Producto> _ofertasFlashFiltradas = [];

  bool _isLoading = true;
  String _mesActual = '';

  @override
  void initState() {
    super.initState();
    // Detectamos el mes actual automáticamente
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    _mesActual = meses[DateTime.now().month - 1];

    _cargarDatos();
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
        return p.activo &&
            (p.nombre.toLowerCase().contains(query) ||
                p.categoriaNombre.toLowerCase().contains(query) ||
                p.vendedorNombre.toLowerCase().contains(query));
      }).toList();

      _ofertasFlashFiltradas = _ofertasFlash.where((p) {
        return p.activo &&
            p.esOfertaFlash &&
            (p.nombre.toLowerCase().contains(query) ||
                p.categoriaNombre.toLowerCase().contains(query) ||
                p.vendedorNombre.toLowerCase().contains(query));
      }).toList();
    });
  }

  Future<void> _cargarDatos() async {
    final resultados = await Future.wait([
      _productoService.getProductos(),
      _productoService.getOfertasFlash(),
    ]);

    setState(() {
      var todosLosProductos = resultados[0];
      todosLosProductos.sort((a, b) {
        if (a.vendedorPremium && !b.vendedorPremium) return -1;
        if (!a.vendedorPremium && b.vendedorPremium) return 1;
        return 0;
      });

      _productos = todosLosProductos;
      _productosFiltrados = _productos.where((p) => p.activo).toList();

      var todasLasOfertas = resultados[1];
      todasLasOfertas.sort((a, b) {
        if (a.vendedorPremium && !b.vendedorPremium) return -1;
        if (!a.vendedorPremium && b.vendedorPremium) return 1;
        return 0;
      });

      _ofertasFlash = todasLasOfertas;
      _ofertasFlashFiltradas = _ofertasFlash
          .where((p) => p.activo && p.esOfertaFlash)
          .toList();

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _cargarDatos,
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '⚡ Ofertas Flash',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (_ofertasFlashFiltradas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'No hay ofertas flash que coincidan.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 330,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _ofertasFlashFiltradas.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, index) => _buildProductoCard(
                    _ofertasFlashFiltradas[index],
                    isFlash: true,
                  ),
                ),
              ),
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _productosFiltrados.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) => _buildProductoCard(
                  _productosFiltrados[index],
                  isFlash: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

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
            Stack(
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
                          child: Image.network(
                            producto.imagen!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                if (producto.mesesTemporada.contains(_mesActual))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.green.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '🌟 Temporada de $_mesActual',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          producto.mesesTemporada,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    // LÓGICA DE NAVEGACIÓN ASÍNCRONA CORREGIDA
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cargando perfil...'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );

                      try {
                        final vendedorService = VendedorService();
                        final todosLosVendedores = await vendedorService
                            .getVendedores();

                        final vendedorCompleto = todosLosVendedores.firstWhere(
                          (v) => v.id == producto.vendedorId,
                        );

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendedorDetailScreen(
                                vendedor: vendedorCompleto,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error al cargar el perfil del productor',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 14,
                            color: producto.vendedorPremium
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              producto.vendedorNombre.isEmpty
                                  ? 'Vendedor'
                                  : producto.vendedorNombre,
                              style: TextStyle(
                                fontSize: 12,
                                color: producto.vendedorPremium
                                    ? Colors.amber.shade900
                                    : Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: producto.vendedorPremium
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (producto.vendedorPremium)
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                        ],
                      ),
                    ),
                  ),
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
