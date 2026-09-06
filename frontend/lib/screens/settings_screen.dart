import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificaciones = true;
  bool _solicitudPremiumEnviada = false;
  final TextEditingController _codigoCtrl = TextEditingController();
  bool _isProcessing = false;

  Future<void> _validarCodigo(String rol) async {
    if (_codigoCtrl.text.trim() == "12345678") {
      setState(() => _isProcessing = true);
      // Mandamos el parche al backend
      Map<String, String> datos = {'es_premium': 'true'};
      if (rol == 'comercios') datos = {'es_comprador_comercios': 'true'};

      bool exito = await AuthService().actualizarPerfil(datos, null);
      setState(() => _isProcessing = false);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Felicidades! Tu cuenta ha sido mejorada.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Cierra la pantalla para refrescar
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _simularEnvioCorreo() {
    setState(() => _solicitudPremiumEnviada = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud enviada a alexjiro464@mail.com'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSeller = Provider.of<AuthProvider>(context).userRol == 2;
    final Color themeColor = isSeller ? Colors.amber : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: isSeller
            ? Colors.amber.shade100
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Preferencias de la Aplicación',
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibe avisos de tus pedidos'),
            value: _notificaciones,
            activeColor: themeColor,
            onChanged: (val) => setState(() => _notificaciones = val),
          ),
          const Divider(),
          Text(
            'Suscripciones (Hackathon)',
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (!_solicitudPremiumEnviada) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                'Solicitar Membresía Premium',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              onPressed: _simularEnvioCorreo,
            ),
          ] else ...[
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Ingresa el código que recibiste en tu correo (Prueba: 12345678):',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _codigoCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Código de Activación',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => setState(
                                  () => _solicitudPremiumEnviada = false,
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _validarCodigo('premium'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                ),
                                child: const Text(
                                  'Validar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],

          // Si es Comprador (Rol 3), mostramos también la opción de Comercios
          if (!isSeller) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.store, color: Colors.white),
              label: const Text(
                'Convertirme en Comprador de Comercios',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () =>
                  _simularEnvioCorreo(), // Simula el mismo flujo por practicidad
            ),
          ],
        ],
      ),
    );
  }
}
