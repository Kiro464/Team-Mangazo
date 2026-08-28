import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendedor.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/cart_provider.dart';

class VendedorDetailScreen extends StatefulWidget {
  final Vendedor vendedor;

  const VendedorDetailScreen({super.key, required this.vendedor});

  @override
  State<VendedorDetailScreen> createState() => _VendedorDetailScreenState();
}

class _VendedorDetailScreenState extends State<VendedorDetailScreen> {
  List<Producto> _productosVendedor = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProductosDelVendedor();
  }

  Future<void> _cargarProductosDelVendedor() async {
    // Descargamos todos los productos y filtramos localmente los de este vendedor
    final todos = await ProductoService().getProductos();
    setState(() {
      _productosVendedor = todos
          .where(
            (p) => p.vendedorNombre.toLowerCase().contains(
              widget.vendedor.firstName.toLowerCase(),
            ),
          )
          .toList();
      _isLoading = false;
    });
  }

  void _contactarWhatsApp() async {
    if (widget.vendedor.telefonoWhatsapp == null ||
        widget.vendedor.telefonoWhatsapp!.isEmpty)
      return;
    final url = Uri.parse(
      "https://wa.me/${widget.vendedor.telefonoWhatsapp}?text=Hola%20${widget.vendedor.firstName},%20vi%20sus%20productos%20en%20Mangazo.",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendedor.nombreCompleto),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de Perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: widget.vendedor.fotoPerfil != null
                        ? NetworkImage(widget.vendedor.fotoPerfil!)
                        : null,
                    child: widget.vendedor.fotoPerfil == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.vendedor.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.vendedor.esPremium) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${widget.vendedor.username}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (widget.vendedor.telefonoWhatsapp != null &&
                      widget.vendedor.telefonoWhatsapp!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _contactarWhatsApp,
                      icon: const Icon(Icons.chat),
                      label: const Text('Contactar por WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // Historia / Biografía
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌾 Historia del Productor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.vendedor.historiaVendedor ??
                        'Este productor aún no ha agregado su historia, pero cultiva con gran dedicación para llevar lo mejor a tu mesa.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Catálogo del Vendedor
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '🍎 Cosechas de ${widget.vendedor.firstName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _productosVendedor.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Este vendedor no tiene productos activos en este momento.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _productosVendedor.length,
                    itemBuilder: (context, index) {
                      final p = _productosVendedor[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'C\$ ${p.precioReferencial} • ${p.categoriaNombre}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).addItem(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${p.nombre} agregado al carrito',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
