import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../services/pedido_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // --- CUADRO DE DIÁLOGO DE CONFIRMACIÓN ---
  void _mostrarConfirmacion(
    BuildContext context,
    CartProvider cart,
    List<CartItem> listaItems,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('¿Completaste tu pedido?'),
              content: const Text(
                'Confirma si lograste enviar el mensaje por WhatsApp a nuestro vendedor.',
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
                            listaItems,
                          );

                          if (pedidoId != null) {
                            cart.clear(); // Vaciamos el carrito
                            if (context.mounted) {
                              Navigator.pop(dialogContext); // Cerramos diálogo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '¡Pedido registrado! Podrás confirmarlo cuando lo recibas.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            setState(() => isProcessing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error guardando en el servidor'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
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

  // --- INTERFAZ PRINCIPAL DEL CARRITO ---
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío 🛒\n¡Agrega algunos productos!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            child: Text(
                              '${cartItem.cantidad}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            cartItem.producto.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Total: C\$ ${cartItem.producto.precioReferencial * cartItem.cantidad}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                cart.removeItem(cartItem.producto.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a pagar:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'C\$ ${cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                final listaItems = cart.items.values.toList();
                                String mensaje =
                                    "🥭 *NUEVO PEDIDO DE MANGAZO* 🥭\n\nHola, quiero realizar la siguiente compra:\n\n";
                                for (var item in listaItems) {
                                  mensaje +=
                                      "🔸 ${item.cantidad}x ${item.producto.nombre} (C\$ ${item.producto.precioReferencial})\n";
                                }
                                mensaje +=
                                    "\n*💰 Total a pagar: C\$ ${cart.totalAmount.toStringAsFixed(2)}*";

                                const String numeroVendedor = "50588887777";
                                final Uri whatsappUrl = Uri.parse(
                                  "https://wa.me/$numeroVendedor?text=${Uri.encodeComponent(mensaje)}",
                                );

                                try {
                                  await launchUrl(
                                    whatsappUrl,
                                    mode: LaunchMode.platformDefault,
                                  );
                                  if (context.mounted)
                                    _mostrarConfirmacion(
                                      context,
                                      cart,
                                      listaItems,
                                    );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo abrir el enlace: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.chat),
                        label: const Text(
                          'Comprar vía WhatsApp',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
