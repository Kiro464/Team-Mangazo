import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vendedor.dart';
import '../services/auth_service.dart';

class SellerEditProfileScreen extends StatefulWidget {
  final Vendedor perfilActual;
  const SellerEditProfileScreen({super.key, required this.perfilActual});

  @override
  State<SellerEditProfileScreen> createState() =>
      _SellerEditProfileScreenState();
}

class _SellerEditProfileScreenState extends State<SellerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _telefonoCtrl;
  late TextEditingController _historiaCtrl;
  late TextEditingController _youtubeCtrl;
  late TextEditingController _redesCtrl;

  File? _nuevaFoto;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _telefonoCtrl = TextEditingController(
      text: widget.perfilActual.telefonoWhatsapp ?? '',
    );
    _historiaCtrl = TextEditingController(
      text: widget.perfilActual.historiaVendedor ?? '',
    );
    _youtubeCtrl = TextEditingController(
      text: widget.perfilActual.videoYoutube ?? '',
    );
    _redesCtrl = TextEditingController(
      text: widget.perfilActual.linkRedes ?? '',
    );
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) setState(() => _nuevaFoto = File(pickedFile.path));
  }

  Future<void> _guardar() async {
    setState(() => _isSubmitting = true);
    Map<String, String> datos = {
      'telefono_whatsapp': _telefonoCtrl.text,
      'historia_vendedor': _historiaCtrl.text,
      'video_youtube': _youtubeCtrl.text,
      'link_redes': _redesCtrl.text,
    };
    bool exito = await AuthService().actualizarPerfil(datos, _nuevaFoto);
    setState(() => _isSubmitting = false);

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Retornamos true para recargar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mi Perfil Público'),
        backgroundColor: Colors.amber.shade100,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _nuevaFoto != null
                          ? FileImage(_nuevaFoto!)
                          : (widget.perfilActual.fotoPerfil != null
                                    ? NetworkImage(
                                        widget.perfilActual.fotoPerfil!,
                                      )
                                    : null)
                                as ImageProvider?,
                      child:
                          _nuevaFoto == null &&
                              widget.perfilActual.fotoPerfil == null
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Toca para cambiar foto',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _telefonoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp (Ej: 50588887777)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.chat),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _youtubeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Link Video de YouTube (Opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.play_circle_filled),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _historiaCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Tu Historia (¡Enamora a tus clientes!)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
