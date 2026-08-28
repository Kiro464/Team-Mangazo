import 'package:flutter/material.dart';
import '../models/vendedor.dart';
import '../models/producto.dart';
import '../services/vendedor_service.dart';
import '../services/producto_service.dart'; // <-- IMPORTAMOS ESTO
import 'vendedor_detail_screen.dart';

class VendedoresScreen extends StatefulWidget {
  const VendedoresScreen({super.key});

  @override
  State<VendedoresScreen> createState() => _VendedoresScreenState();
}

class _VendedoresScreenState extends State<VendedoresScreen> {
  final VendedorService _vendedorService = VendedorService();
  final ProductoService _productoService = ProductoService();
  final TextEditingController _searchController = TextEditingController();

  List<Vendedor> _vendedores = [];
  List<Vendedor> _vendedoresFiltrados = [];
  List<Producto> _todosLosProductos = []; // Para buscar por productos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(_filtrarVendedores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final resultados = await Future.wait([
      _vendedorService.getVendedores(),
      _productoService.getProductos(),
    ]);

    List<Vendedor> vendedoresDescargados = resultados[0] as List<Vendedor>;

    // ORDENAMOS DE MAYOR A MENOR CALIFICACIÓN
    vendedoresDescargados.sort(
      (a, b) => b.promedioCalificaciones.compareTo(a.promedioCalificaciones),
    );

    setState(() {
      _vendedores = vendedoresDescargados;
      _vendedoresFiltrados = vendedoresDescargados;
      _todosLosProductos = resultados[1] as List<Producto>;
      _isLoading = false;
    });
  }

  void _filtrarVendedores() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _vendedoresFiltrados = _vendedores.where((vendedor) {
        // 1. ¿Coincide el nombre del vendedor?
        bool coincideNombre = vendedor.nombreCompleto.toLowerCase().contains(
          query,
        );

        // 2. ¿Tiene algún producto o categoría que coincida?
        bool coincideProducto = _todosLosProductos.any((producto) {
          return producto.vendedorId == vendedor.id &&
              (producto.nombre.toLowerCase().contains(query) ||
                  producto.categoriaNombre.toLowerCase().contains(query));
        });

        return coincideNombre || coincideProducto;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      40,
                      20,
                      20,
                    ), // Un poco más de padding arriba
                    color: Colors.green.shade100,
                    child: Column(
                      children: [
                        const Icon(Icons.store, size: 40, color: Colors.green),
                        const SizedBox(height: 8),
                        const Text(
                          'Nuestros Productores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- BARRA DE BÚSQUEDA DE VENDEDORES ---
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Buscar por nombre, producto o categoría...',
                            hintStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.green,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _vendedoresFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron vendedores.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _vendedoresFiltrados.length,
                            itemBuilder: (context, index) {
                              final v = _vendedoresFiltrados[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: v.fotoPerfil != null
                                        ? NetworkImage(v.fotoPerfil!)
                                        : null,
                                    child: v.fotoPerfil == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        v.nombreCompleto,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (v.esPremium) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Mostramos la calificación en el subtítulo
                                  subtitle: Text(
                                    '⭐ ${v.promedioCalificaciones} • ${v.historiaVendedor ?? "Productor local"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VendedorDetailScreen(vendedor: v),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
