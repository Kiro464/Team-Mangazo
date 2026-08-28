import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../services/pedido_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // --- 1. CUADRO DE DIÁLOGO DE LA ENCUESTA ---
  void _mostrarEncuesta(BuildContext context, int pedidoId) {
    int calificacion = 5;
    TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '¡Gracias por tu compra!',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cómo calificarías tu experiencia?'),
                  const SizedBox(height: 16),
                  // Generador de Estrellas interactivas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < calificacion ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () =>
                            setState(() => calificacion = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: comentarioController,
                    decoration: const InputDecoration(
                      hintText: 'Déjanos un comentario (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), // Omitir
                  child: const Text(
                    'Omitir',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await PedidoService().enviarResena(
                      pedidoId,
                      calificacion,
                      comentarioController.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(dialogContext); // Cierra la encuesta
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '¡Reseña enviada! Gracias por tu feedback.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Enviar Reseña'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 2. CUADRO DE DIÁLOGO DE CONFIRMACIÓN ---
  void _mostrarConfirmacion(
    BuildContext context,
    CartProvider cart,
    List<CartItem> listaItems,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a tocar un botón
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
                      : () => Navigator.pop(
                          dialogContext,
                        ), // Solo cierra, no borra el carrito
                  child: const Text(
                    'No, cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          setState(
                            () => isProcessing = true,
                          ); // Muestra cargando

                          // Solo si dice que sí, guardamos en Django
                          int? pedidoId = await PedidoService().enviarPedido(
                            listaItems,
                          );

                          if (pedidoId != null) {
                            cart.clear(); // Vaciamos el carrito
                            if (context.mounted)
                              Navigator.pop(
                                dialogContext,
                              ); // Cerramos confirmación
                            if (context.mounted)
                              _mostrarEncuesta(
                                context,
                                pedidoId,
                              ); // Lanzamos encuesta
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

  // --- 3. INTERFAZ PRINCIPAL DEL CARRITO ---
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

                                // 1. Preparamos el enlace de WhatsApp
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

                                // 2. Lanzamos WhatsApp
                                try {
                                  await launchUrl(
                                    whatsappUrl,
                                    mode: LaunchMode.platformDefault,
                                  );
                                  // 3. Cuando el usuario regrese a la app, lanzamos la confirmación
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
