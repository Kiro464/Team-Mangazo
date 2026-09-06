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
    var lista = await _pedidoService.getMisPedidos();

    // ORDENAR: Comercios primero, Premium segundo, Normales después.
    lista.sort((a, b) {
      if (a.compradorComercios && !b.compradorComercios) return -1;
      if (!a.compradorComercios && b.compradorComercios) return 1;

      if (a.compradorPremium && !b.compradorPremium) return -1;
      if (!a.compradorPremium && b.compradorPremium) return 1;

      return 0; // Si son iguales, no se mueven
    });

    _pedidos = lista;
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
                        // NUEVO: Agrupamos los estados exitosos
                        final bool esExito =
                            pedido.estado == 'Aceptado' ||
                            pedido.estado == 'Completado' ||
                            pedido.estado == 'Entregado';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: Icon(
                              esPendiente
                                  ? Icons.notification_important
                                  : (esExito
                                        ? Icons.check_circle
                                        : Icons.cancel),
                              color: esPendiente
                                  ? Colors.orange
                                  : (esExito ? Colors.green : Colors.red),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Pedido #${pedido.id} - ${pedido.compradorNombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Ícono de Comercio (Azul)
                                if (pedido.compradorComercios) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.store,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                ],
                                // Ícono Premium (Estrella Ámbar, solo si no es comercio)
                                if (pedido.compradorPremium &&
                                    !pedido.compradorComercios) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                            // Usamos la nueva variable 'esExito' aquí también:
                            subtitle: Text(
                              'Estado: ${pedido.estado}',
                              style: TextStyle(
                                color: esPendiente
                                    ? Colors.orange[800]
                                    : (esExito ? Colors.green : Colors.red),
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
                              if (esPendiente)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await _pedidoService
                                            .actualizarEstadoPedido(
                                              pedido.id,
                                              'Cancelado',
                                            );
                                        _cargarPedidos();
                                      },
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () async {
                                        await _pedidoService
                                            .actualizarEstadoPedido(
                                              pedido.id,
                                              'Aceptado',
                                            );
                                        _cargarPedidos();
                                      },
                                      child: const Text(
                                        'Aceptar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
