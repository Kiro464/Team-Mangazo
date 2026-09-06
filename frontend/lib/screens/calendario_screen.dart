import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../providers/cart_provider.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productosTemporada = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTemporada();
  }

  Future<void> _cargarTemporada() async {
    final resultados = await _productoService.getCalendarioTemporada();
    setState(() {
      _productosTemporada = resultados;
      _isLoading = false;
    });
  }

  // Lista de meses para mostrar el nombre del mes actual de forma amigable
  final List<String> meses = [
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
  String getMesActual() => meses[DateTime.now().month - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.orange.shade100,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 50,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cosechas de ${getMesActual()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const Text(
                        'Productos frescos de temporada',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _productosTemporada.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay productos registrados para esta temporada.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: _productosTemporada.length,
                          itemBuilder: (context, index) {
                            final producto = _productosTemporada[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.eco, color: Colors.white),
                              ),
                              title: Text(
                                producto.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Vendedor: ${producto.vendedorNombre} • C\$ ${producto.precioReferencial}',
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
                                  ).addItem(producto);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${producto.nombre} agregado al carrito',
                                      ),
                                      duration: const Duration(seconds: 1),
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
    );
  }
}
