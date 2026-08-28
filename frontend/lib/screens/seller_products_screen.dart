import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/vendedor.dart';
import '../services/producto_service.dart';
import '../services/auth_service.dart';

// import 'add_product_screen.dart'; // Lo usaremos en el siguiente paso

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _misProductos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMisProductos();
  }

  Future<void> _cargarMisProductos() async {
    setState(() => _isLoading = true);
    Vendedor? miPerfil = await AuthService().getCurrentUser();

    if (miPerfil != null) {
      final todos = await _productoService.getProductos();
      // Filtramos solo los productos donde el vendedorId coincida con mi ID
      _misProductos = todos.where((p) => p.vendedorId == miPerfil.id).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Catálogo'),
        backgroundColor: Colors.amber.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarMisProductos,
              child: _misProductos.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes productos activos.\n¡Agrega tu primera cosecha!',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _misProductos.length,
                      itemBuilder: (context, index) {
                        final p = _misProductos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: p.imagen != null
                                ? Image.network(
                                    p.imagen!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 50),
                            title: Text(
                              p.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'C\$ ${p.precioReferencial} • ${p.categoriaNombre}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueGrey,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edición disponible en fase 2',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      // Botón flotante para agregar producto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())).then((_) => _cargarMisProductos());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abriendo cámara... (Siguiente paso)'),
            ),
          );
        },
        backgroundColor: Colors.amber.shade600,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nuevo Producto'),
      ),
    );
  }
}
