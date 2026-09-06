import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _cargarProductosDelVendedor();
    _inicializarVideo();
  }

  void _inicializarVideo() {
    if (widget.vendedor.videoYoutube != null &&
        widget.vendedor.videoYoutube!.isNotEmpty) {
      final videoId = YoutubePlayerController.convertUrlToId(
        widget.vendedor.videoYoutube!,
      );

      if (videoId != null) {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            mute: false,
            showControls: true,
            showFullscreenButton: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  Future<void> _cargarProductosDelVendedor() async {
    final todos = await ProductoService().getProductos();
    setState(() {
      // Filtrado exacto por ID, no por nombre
      _productosVendedor = todos
          .where((p) => p.vendedorId == widget.vendedor.id)
          .toList();
      _isLoading = false;
    });
  }

  void _abrirUrl(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    final Uri url = Uri.parse(urlStr);
    try {
      // Ignoramos canLaunchUrl y forzamos la apertura directa
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('No se pudo abrir la URL: $e');
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
            // --- 1. CABECERA Y DATOS DE CONTACTO ---
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
                        ? const Icon(Icons.store, size: 50, color: Colors.grey)
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
                  const SizedBox(height: 8),
                  // Calificación Promedio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.vendedor.promedioCalificaciones} / 5.0',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ' (${widget.vendedor.resenas.length} reseñas)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones de Contacto
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      if (widget.vendedor.telefonoWhatsapp != null)
                        IconButton(
                          icon: const Icon(
                            Icons.chat,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed: () => _abrirUrl(
                            "https://wa.me/${widget.vendedor.telefonoWhatsapp!.replaceAll('+', '')}",
                          ),
                        ),
                      if (widget.vendedor.email.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.email,
                            color: Colors.blue,
                            size: 30,
                          ),
                          onPressed: () =>
                              _abrirUrl("mailto:${widget.vendedor.email}"),
                        ),
                      if (widget.vendedor.linkRedes != null)
                        IconButton(
                          icon: const Icon(
                            Icons.language,
                            color: Colors.purple,
                            size: 30,
                          ),
                          onPressed: () => _abrirUrl(widget.vendedor.linkRedes),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 2. HISTORIA Y VIDEO ---
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
                        'Productor local comprometido con la calidad.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_ytController != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: YoutubePlayer(
                        controller: _ytController!,
                        aspectRatio: 16 / 9,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Video no disponible',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(),

            // --- 3. RESEÑAS DE COMPRADORES ---
            if (widget.vendedor.resenas.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '💬 Reseñas de Clientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.vendedor.resenas.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, index) {
                    final resena = widget.vendedor.resenas[index];
                    return Container(
                      width: 250,
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  resena.compradorNombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  Text(resena.calificacion.toString()),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            resena.fecha,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              resena.comentario.isEmpty
                                  ? 'Sin comentario.'
                                  : resena.comentario,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],

            // --- 4. CATÁLOGO ESTRICTO DEL VENDEDOR ---
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
                      child: Text('Este vendedor no tiene productos activos.'),
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
                          leading: p.imagen != null
                              ? Image.network(
                                  p.imagen!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),
                          title: Text(
                            p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('C\$ ${p.precioReferencial}'),
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
