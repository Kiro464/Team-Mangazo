import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/vendedor.dart';
import '../services/producto_service.dart';
import '../services/auth_service.dart';
import 'add_product_screen.dart';

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

      _misProductos.sort((a, b) => a.id.compareTo(b.id));
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'C\$ ${p.precioReferencial} - ${p.categoriaNombre}',
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.activo
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p.activo ? 'Visible' : 'Oculto',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: p.activo
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                    if (p.esOfertaFlash) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.flash_on,
                                              size: 12,
                                              color: Colors.amber.shade900,
                                            ),
                                            Text(
                                              'Oferta Flash',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- INTERRUPTOR 1: OFERTA FLASH (RAYO) ---
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.flash_on,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        value: p.esOfertaFlash,
                                        activeColor: Colors.amber,
                                        onChanged: (val) async {
                                          await _productoService
                                              .actualizarBooleano(
                                                p.id,
                                                'es_oferta_flash',
                                                val,
                                              );
                                          _cargarMisProductos();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                // --- INTERRUPTOR 2: ACTIVO EN CATÁLOGO (OJO) ---
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.visibility,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        value: p.activo,
                                        activeColor: Colors.blue,
                                        onChanged: (val) async {
                                          await _productoService
                                              .actualizarBooleano(
                                                p.id,
                                                'activo',
                                                val,
                                              );
                                          _cargarMisProductos();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                // --- BOTÓN DE EDITAR ---
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Colors.blueGrey,
                                    size: 28,
                                  ),
                                  tooltip: 'Editar producto',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddProductScreen(
                                          productoAEditar: p,
                                        ),
                                      ),
                                    ).then((_) => _cargarMisProductos());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      // Botón flotante para agregar producto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Al regresar de la pantalla, recargamos la lista automáticamente
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => _cargarMisProductos());
        },
        backgroundColor: Colors.amber.shade600,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Nuevo Producto',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
