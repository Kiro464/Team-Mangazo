import 'package:flutter/material.dart';
import '../models/vendedor.dart';
import '../services/vendedor_service.dart';
import 'vendedor_detail_screen.dart';

class VendedoresScreen extends StatefulWidget {
  const VendedoresScreen({super.key});

  @override
  State<VendedoresScreen> createState() => _VendedoresScreenState();
}

class _VendedoresScreenState extends State<VendedoresScreen> {
  final VendedorService _vendedorService = VendedorService();
  List<Vendedor> _vendedores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVendedores();
  }

  Future<void> _cargarVendedores() async {
    final resultados = await _vendedorService.getVendedores();
    setState(() {
      _vendedores = resultados;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarVendedores,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.green.shade100,
                    child: const Column(
                      children: [
                        Icon(Icons.store, size: 40, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          'Nuestros Productores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Conoce a las manos que cultivan tus alimentos',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _vendedores.isEmpty
                        ? const Center(
                            child: Text('No hay vendedores registrados.'),
                          )
                        : ListView.builder(
                            itemCount: _vendedores.length,
                            itemBuilder: (context, index) {
                              final v = _vendedores[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: v.fotoPerfil != null
                                        ? NetworkImage(v.fotoPerfil!)
                                        : null,
                                    child: v.fotoPerfil == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        v.nombreCompleto,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (v.esPremium) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    v.historiaVendedor != null
                                        ? v.historiaVendedor!
                                        : 'Productor local',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VendedorDetailScreen(vendedor: v),
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
            ),
    );
  }
}
