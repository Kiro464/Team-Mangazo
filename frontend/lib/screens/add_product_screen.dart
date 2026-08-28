import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/producto_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();

  // Controladores de texto
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();

  // Asumimos los IDs de las categorías según el script semilla
  String _categoriaSeleccionada = '1';
  final Map<String, String> _categorias = {
    'Frutas': '1',
    'Verduras': '2',
    'Granos Básicos': '3',
    'Lácteos y Derivados': '4',
    'Carnes': '5',
  };

  File? _imagenSeleccionada;
  bool _isSubmitting = false;

  // Función para abrir la cámara o galería
  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    ); // Comprimimos la calidad al 70%

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  // Cuadro de diálogo para elegir de dónde sacar la foto
  void _mostrarOpcionesDeImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.amber),
              title: const Text('Elegir de Galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate())
      return; // Valida que no haya campos vacíos

    setState(() => _isSubmitting = true);

    // Preparamos los textos
    Map<String, String> datos = {
      'nombre': _nombreCtrl.text,
      'descripcion': _descripcionCtrl.text,
      'precio_referencial': _precioCtrl.text,
      'categoria': _categoriaSeleccionada,
    };

    // Enviamos a Django
    bool exito = await _productoService.crearProducto(
      datos,
      _imagenSeleccionada,
    );

    setState(() => _isSubmitting = false);

    if (exito) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cosecha registrada exitosamente 🌱'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Cierra la pantalla y regresa al catálogo
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cosecha'),
        backgroundColor: Colors.amber.shade100,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- ÁREA DE FOTO ---
                  GestureDetector(
                    onTap: _mostrarOpcionesDeImagen,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade300,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _imagenSeleccionada != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imagenSeleccionada!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Toca para agregar una foto',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CAMPOS DE TEXTO ---
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor ingresa un nombre' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _categoriaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categorias.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _categoriaSeleccionada = val!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio (C\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingresa el precio';
                      if (double.tryParse(value) == null)
                        return 'Ingresa un número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (Opcional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- BOTÓN DE GUARDAR ---
                  ElevatedButton(
                    onPressed: _guardarProducto,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Publicar Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
