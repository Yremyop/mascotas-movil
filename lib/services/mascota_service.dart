import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/mascota.dart';

/// CRUD de la colección "mascotas" en Cloud Firestore.
/// Cada documento guarda el UID de su dueño en el campo "uid".
class MascotaService {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('mascotas');

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // CREATE
  Future<void> crear({
    required String nombre,
    required String especie,
    required int edad,
    required String descripcion,
    required String imagenUrl,
  }) async {
    await _coleccion.add({
      'uid': _uid,
      'nombre': nombre,
      'especie': especie,
      'edad': edad,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'creadoEn': FieldValue.serverTimestamp(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  // READ: solo las mascotas del usuario autenticado, en tiempo real.
  Stream<List<Mascota>> misMascotas() {
    return _coleccion.where('uid', isEqualTo: _uid).snapshots().map((snap) {
      final lista = snap.docs.map(Mascota.fromDoc).toList();
      // Más recientes primero (se ordena aquí para no requerir un índice compuesto).
      lista.sort((a, b) => (b.creadoEn ?? DateTime.now())
          .compareTo(a.creadoEn ?? DateTime.now()));
      return lista;
    });
  }

  // READ: un documento por su id.
  Stream<Mascota?> mascota(String id) {
    return _coleccion
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Mascota.fromDoc(doc) : null);
  }

  // UPDATE
  Future<void> actualizar(
    String id, {
    required String nombre,
    required String especie,
    required int edad,
    required String descripcion,
    required String imagenUrl,
  }) async {
    await _coleccion.doc(id).update({
      'nombre': nombre,
      'especie': especie,
      'edad': edad,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}
