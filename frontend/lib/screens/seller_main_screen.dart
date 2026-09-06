import 'package:flutter/material.dart';
import 'seller_products_screen.dart';
import 'seller_orders_screen.dart';
import 'settings_screen.dart'; // Reutilizamos esta pantalla
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/vendedor.dart';
import 'vendedor_detail_screen.dart';
import 'seller_edit_profile_screen.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SellerProductsScreen(),
    const SellerOrdersScreen(),
    _MiPerfilVendedorTab(),
    const SettingsScreen(), // Reutilizamos tu pantalla de configuración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mangazo - Productores',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Cerrar Sesión',
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.amber.shade800,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Mis Cosechas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class _MiPerfilVendedorTab extends StatefulWidget {
  @override
  State<_MiPerfilVendedorTab> createState() => _MiPerfilVendedorTabState();
}

class _MiPerfilVendedorTabState extends State<_MiPerfilVendedorTab> {
  Vendedor? miPerfil;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final perfil = await AuthService().getCurrentUser();
    setState(() => miPerfil = perfil);
  }

  @override
  Widget build(BuildContext context) {
    if (miPerfil == null)
      return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: VendedorDetailScreen(
        vendedor: miPerfil!,
      ), // Reutilizamos tu hermosa pantalla
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final actualizo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SellerEditProfileScreen(perfilActual: miPerfil!),
            ),
          );
          if (actualizo == true) _cargar();
        },
        backgroundColor: Colors.amber.shade600,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
