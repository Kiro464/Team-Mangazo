import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final PedidoService _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    _pedidos = await _pedidoService.getMisPedidos();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Recibidos'),
        backgroundColor: Colors.amber.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPedidos,
              child: _pedidos.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no tienes pedidos.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = _pedidos[index];
                        final bool esPendiente = pedido.estado == 'Pendiente';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: Icon(
                              esPendiente
                                  ? Icons.notification_important
                                  : Icons.check_circle,
                              color: esPendiente ? Colors.orange : Colors.green,
                            ),
                            title: Text(
                              'Pedido - ${pedido.fecha}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              esPendiente
                                  ? 'Estado: Pendiente de entrega'
                                  : 'Estado: Entregado',
                              style: TextStyle(
                                color: esPendiente
                                    ? Colors.orange[800]
                                    : Colors.green,
                              ),
                            ),
                            children: [
                              const Divider(),
                              ...pedido.detalles.map(
                                (detalle) => ListTile(
                                  dense: true,
                                  title: Text(
                                    '${detalle.cantidad}x ${detalle.productoNombre}',
                                  ),
                                  trailing: Text(
                                    'C\$ ${detalle.precio * detalle.cantidad}',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Total a cobrar: C\$ ${pedido.total}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
