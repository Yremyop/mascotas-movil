import 'package:cloud_firestore/cloud_firestore.dart';

class Mascota {
  final String id;
  final String uid;
  final String nombre;
  final String especie;
  final int edad;
  final String descripcion;
  final String imagenUrl;
  final DateTime? creadoEn;

  const Mascota({
    required this.id,
    required this.uid,
    required this.nombre,
    required this.especie,
    required this.edad,
    required this.descripcion,
    required this.imagenUrl,
    this.creadoEn,
  });

  factory Mascota.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Mascota(
      id: doc.id,
      uid: data['uid'] as String,
      nombre: data['nombre'] as String? ?? '',
      especie: data['especie'] as String? ?? '',
      edad: (data['edad'] as num?)?.toInt() ?? 0,
      descripcion: data['descripcion'] as String? ?? '',
      imagenUrl: data['imagenUrl'] as String? ?? '',
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate(),
    );
  }
}
