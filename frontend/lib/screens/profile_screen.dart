import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../services/auth_service.dart';
import '../models/vendedor.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PedidoService _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  Vendedor? _miPerfil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    _miPerfil = await AuthService().getCurrentUser();
    _pedidos = await _pedidoService.getMisPedidos();
    setState(() => _isLoading = false);
  }

  void _mostrarEncuesta(BuildContext context, int pedidoId) {
    int calificacion = 5;
    TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                '¡Gracias por confirmar!',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Cómo calificarías tu experiencia y el producto?',
                  ),
                  const SizedBox(height: 16),
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
                            setStateDialog(() => calificacion = index + 1),
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Omitir',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _pedidoService.enviarResena(
                      pedidoId,
                      calificacion,
                      comentarioController.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Reseña enviada!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPedidos,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: const Text('Mi Perfil'),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                        left: 24,
                        right: 24,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _miPerfil?.nombreCompleto ?? 'Mi Perfil',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${_miPerfil?.username ?? "usuario"}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout(),
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '📦 Historial de Pedidos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_pedidos.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Aún no tienes pedidos en tu historial.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
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
                                  ? Icons.local_shipping
                                  : Icons.check_circle,
                              color: esPendiente ? Colors.orange : Colors.green,
                            ),
                            title: Text(
                              'Pedido - ${pedido.fecha}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vendedor: ${pedido.vendedorNombre}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  esPendiente
                                      ? 'Estado: Esperando entrega'
                                      : 'Estado: Completado',
                                  style: TextStyle(
                                    color: esPendiente
                                        ? Colors.orange[800]
                                        : Colors.green,
                                  ),
                                ),
                              ],
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: C\$ ${pedido.total}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (esPendiente)
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool exito = await _pedidoService
                                              .confirmarEntrega(pedido.id);
                                          if (exito) {
                                            if (context.mounted)
                                              _mostrarEncuesta(
                                                context,
                                                pedido.id,
                                              );
                                            _cargarPedidos();
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Error al confirmar.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Confirmar Entrega'),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: _pedidos.length),
                    ),
                ],
              ),
            ),
    );
  }
}
