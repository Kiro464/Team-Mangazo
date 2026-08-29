import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificaciones = true;
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    // Leemos si es vendedor (rol == 2)
    final bool isSeller = Provider.of<AuthProvider>(context).userRol == 2;
    final Color themeColor = isSeller ? Colors.amber : Colors.green;
    final Color bgColor = isSeller
        ? Colors.amber.shade100
        : Theme.of(context).colorScheme.primary.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: bgColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Preferencias de la Aplicación',
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibe avisos sobre tus pedidos'),
            value: _notificaciones,
            activeColor: themeColor, // <--- Color dinámico
            onChanged: (val) => setState(() => _notificaciones = val),
          ),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambia el tema visual de la app'),
            value: _modoOscuro,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() => _modoOscuro = val);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Característica en desarrollo para la Fase Final',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Acerca de',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión de la App'),
            trailing: const Text('1.0.0 (Hackaton Edition)'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
