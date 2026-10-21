import 'package:firebase_core/firebase_core.dart';

// Valores de la app Web registrada en Firebase Console:
// Configuración del proyecto > General > Tus apps > Configuración del SDK (Config).
// Estos datos identifican el proyecto; no son secretos. La protección real
// de los datos está en las reglas de Firestore (firestore.rules).
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrBVuhyU4q8drLa1wZZIF-IZn8C7OQHX8',
    authDomain: 'movil-flutter-7a74b.firebaseapp.com',
    projectId: 'movil-flutter-7a74b',
    storageBucket: 'movil-flutter-7a74b.firebasestorage.app',
    messagingSenderId: '893438075514',
    appId: '1:893438075514:web:165d7bc319725c1f9191c3',
  );
}
