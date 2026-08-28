import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../services/pedido_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _mostrarConfirmacion(
    BuildContext context,
    CartProvider cart,
    List<CartItem> itemsVendedor,
    int vendedorId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isProcessing = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('¿Completaste el pedido?'),
              content: const Text(
                'Confirma si lograste enviar el mensaje a este vendedor.',
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'No, cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          setState(() => isProcessing = true);
                          int? pedidoId = await PedidoService().enviarPedido(
                            itemsVendedor,
                            vendedorId,
                          );

                          if (pedidoId != null) {
                            cart.removeItemsByVendedor(
                              vendedorId,
                            ); // Solo borra a este vendedor
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pedido registrado exitosamente',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            setState(() => isProcessing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al guardar'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Sí, pedido enviado'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // LÓGICA DE AGRUPACIÓN MULTI-VENDEDOR
    Map<int, List<CartItem>> itemsPorVendedor = {};
    for (var item in cart.items.values) {
      itemsPorVendedor
          .putIfAbsent(item.producto.vendedorId, () => [])
          .add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío 🛒',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: itemsPorVendedor.length,
              itemBuilder: (context, index) {
                int vendedorId = itemsPorVendedor.keys.elementAt(index);
                List<CartItem> itemsDeEsteVendedor =
                    itemsPorVendedor[vendedorId]!;

                String nombreVendedor =
                    itemsDeEsteVendedor.first.producto.vendedorNombre;
                String telefonoVendedor =
                    (itemsDeEsteVendedor.first.producto.vendedorTelefono ??
                            "0000")
                        .replaceAll('+', '');

                double subtotal = itemsDeEsteVendedor.fold(
                  0,
                  (sum, i) => sum + (i.producto.precioReferencial * i.cantidad),
                );

                return Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              nombreVendedor,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...itemsDeEsteVendedor.map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${item.cantidad}x ${item.producto.nombre}',
                            ),
                            subtitle: Text(
                              'C\$ ${item.producto.precioReferencial} c/u',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () =>
                                  cart.removeItem(item.producto.id),
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'C\$ ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            String mensaje =
                                "🥭 *PEDIDO MANGAZO* 🥭\n\nHola $nombreVendedor, quiero pedir:\n\n";
                            for (var item in itemsDeEsteVendedor) {
                              mensaje +=
                                  "🔸 ${item.cantidad}x ${item.producto.nombre}\n";
                            }
                            mensaje +=
                                "\n*💰 Total: C\$ ${subtotal.toStringAsFixed(2)}*";

                            final Uri url = Uri.parse(
                              "https://wa.me/$telefonoVendedor?text=${Uri.encodeComponent(mensaje)}",
                            );
                            try {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                              if (context.mounted)
                                _mostrarConfirmacion(
                                  context,
                                  cart,
                                  itemsDeEsteVendedor,
                                  vendedorId,
                                );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al abrir WhatsApp'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('Comprar a esta tienda'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
