import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pedido_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el carrito para redibujar si el usuario borra algo
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
                      // Obtenemos los productos en forma de lista
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
                            onPressed: () {
                              cart.removeItem(cartItem.producto.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Panel inferior con el Total y Botón de Pago
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
                        // Si el carrito está vacío, deshabilitamos el botón
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Generando pedido... 🚀'),
                                  ),
                                );

                                // 1. Convertimos el diccionario del carrito en una lista
                                final listaItems = cart.items.values.toList();

                                // 2. Enviamos el registro a la base de datos de Django
                                final pedidoService = PedidoService();
                                await pedidoService.enviarPedido(listaItems);

                                // 3. Formateamos un mensaje bonito para WhatsApp
                                String mensaje =
                                    "🥭 *NUEVO PEDIDO DE MANGAZO* 🥭\n\n";
                                mensaje +=
                                    "Hola, quiero realizar la siguiente compra:\n\n";
                                for (var item in listaItems) {
                                  mensaje +=
                                      "🔸 ${item.cantidad}x ${item.producto.nombre} (C\$ ${item.producto.precioReferencial})\n";
                                }
                                mensaje +=
                                    "\n*💰 Total a pagar: C\$ ${cart.totalAmount.toStringAsFixed(2)}*";

                                // 4. Preparamos el enlace de WhatsApp
                                const String numeroVendedor = "50578383900";
                                final Uri whatsappUrl = Uri.parse(
                                  "https://wa.me/$numeroVendedor?text=${Uri.encodeComponent(mensaje)}",
                                );

                                // 5. Lanzamos WhatsApp y vaciamos el carrito
                                try {
                                  await launchUrl(
                                    whatsappUrl,
                                    mode: LaunchMode.platformDefault,
                                  );

                                  cart.clear(); // Vaciamos el carrito tras el éxito
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
