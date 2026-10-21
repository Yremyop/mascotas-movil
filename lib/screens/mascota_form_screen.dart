import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/mascota.dart';
import '../services/cloudinary_service.dart';
import '../services/mascota_service.dart';

/// Formulario para crear (mascota == null) o editar una mascota.
class MascotaFormScreen extends StatefulWidget {
  final Mascota? mascota;

  const MascotaFormScreen({super.key, this.mascota});

  @override
  State<MascotaFormScreen> createState() => _MascotaFormScreenState();
}

class _MascotaFormScreenState extends State<MascotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _especieCtrl;
  late final TextEditingController _edadCtrl;
  late final TextEditingController _descripcionCtrl;

  final _mascotaService = MascotaService();
  final _cloudinaryService = CloudinaryService();

  Uint8List? _imagenBytes;
  String? _imagenNombre;
  String? _estado;

  bool get _esEdicion => widget.mascota != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _especieCtrl = TextEditingController(text: m?.especie ?? '');
    _edadCtrl = TextEditingController(text: m == null ? '' : '${m.edad}');
    _descripcionCtrl = TextEditingController(text: m?.descripcion ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especieCtrl.dispose();
    _edadCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    setState(() {
      _imagenBytes = bytes;
      _imagenNombre = archivo.name;
    });
  }

  Future<void> _guardar() async {
    final formularioValido = _formKey.currentState!.validate();
    if (!_esEdicion && _imagenBytes == null) {
      _mostrarMensaje('Selecciona una imagen para la mascota.', error: true);
      return;
    }
    if (!formularioValido) return;

    try {
      // 1) Si hay imagen nueva, se sube a Cloudinary y se obtiene la URL segura.
      var imagenUrl = widget.mascota?.imagenUrl ?? '';
      if (_imagenBytes != null) {
        setState(() => _estado = 'Subiendo imagen a Cloudinary...');
        imagenUrl = await _cloudinaryService.subirImagen(
            _imagenBytes!, _imagenNombre ?? 'mascota.jpg');
      }

      // 2) Se guardan los datos y la URL en Firestore.
      setState(() => _estado = 'Guardando en Firestore...');
      final nombre = _nombreCtrl.text.trim();
      final especie = _especieCtrl.text.trim();
      final edad = int.parse(_edadCtrl.text.trim());
      final descripcion = _descripcionCtrl.text.trim();

      if (_esEdicion) {
        await _mascotaService.actualizar(
          widget.mascota!.id,
          nombre: nombre,
          especie: especie,
          edad: edad,
          descripcion: descripcion,
          imagenUrl: imagenUrl,
        );
      } else {
        await _mascotaService.crear(
          nombre: nombre,
          especie: especie,
          edad: edad,
          descripcion: descripcion,
          imagenUrl: imagenUrl,
        );
      }

      _mostrarMensaje(_esEdicion
          ? 'Mascota actualizada correctamente.'
          : 'Mascota registrada correctamente.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _mostrarMensaje('No se pudo guardar: $e', error: true);
      if (mounted) setState(() => _estado = null);
    }
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: error ? Colors.red.shade700 : null,
    ));
  }

  String? _requerido(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'El campo $campo es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final guardando = _estado != null;

    Widget vistaImagen;
    if (_imagenBytes != null) {
      vistaImagen = Image.memory(_imagenBytes!, fit: BoxFit.cover);
    } else if (_esEdicion) {
      vistaImagen = Image.network(widget.mascota!.imagenUrl, fit: BoxFit.cover);
    } else {
      vistaImagen = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo, size: 48),
            SizedBox(height: 8),
            Text('Sin imagen seleccionada'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(_esEdicion ? 'Editar mascota' : 'Nueva mascota')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 220,
                    color: Colors.teal.shade50,
                    child: vistaImagen,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: guardando ? null : _elegirImagen,
                  icon: const Icon(Icons.image),
                  label: Text(_imagenBytes == null && !_esEdicion
                      ? 'Elegir imagen'
                      : 'Cambiar imagen'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre', border: OutlineInputBorder()),
                  validator: (v) => _requerido(v, 'nombre'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _especieCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Especie (perro, gato, ...)',
                      border: OutlineInputBorder()),
                  validator: (v) => _requerido(v, 'especie'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _edadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Edad (años)', border: OutlineInputBorder()),
                  validator: (v) {
                    final error = _requerido(v, 'edad');
                    if (error != null) return error;
                    final edad = int.tryParse(v!.trim());
                    if (edad == null || edad < 0 || edad > 50) {
                      return 'Ingresa una edad válida (0 a 50)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Descripción', border: OutlineInputBorder()),
                  validator: (v) => _requerido(v, 'descripción'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: guardando ? null : _guardar,
                  icon: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_estado ?? 'Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
