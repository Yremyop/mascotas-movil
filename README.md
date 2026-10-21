# Mis Mascotas: Flutter + Firebase + Cloudinary

App Flutter (Web) para registrar mascotas (nombre, especie, edad, descripción y foto).

| Servicio | Qué hace en la app | Archivo |
|---|---|---|
| Firebase Authentication | Registro, login y logout con correo/contraseña | `lib/services/auth_service.dart`, `lib/main.dart` (AuthGate) |
| Cloud Firestore | CRUD de la colección `mascotas`, cada doc con el `uid` del dueño | `lib/services/mascota_service.dart`, `firestore.rules` |
| Cloudinary | Sube la foto (unsigned preset) y devuelve `secure_url`, que se guarda en Firestore | `lib/services/cloudinary_service.dart` |

## 1. Firebase (consola web, ~5 min)

1. https://console.firebase.google.com → **Agregar proyecto** (puedes desactivar Analytics).
2. **Authentication** → Comenzar → **Correo electrónico/contraseña** → Habilitar.
3. **Firestore Database** → Crear base de datos → modo producción → región cercana.
4. Firestore → pestaña **Reglas** → pega el contenido de `firestore.rules` → **Publicar**.
5. ⚙️ Configuración del proyecto → **Tus apps** → icono Web `</>` → registra la app
   (sin Hosting) → copia los valores de `firebaseConfig` en `lib/firebase_options.dart`.

## 2. Cloudinary (~3 min)

1. Crea cuenta gratis en https://cloudinary.com. En el Dashboard copia el **Cloud name**.
2. Settings (⚙️) → **Upload** → **Upload presets** → Add upload preset:
   - Signing mode: **Unsigned**
   - Nombre: `mascotas_unsigned`, Asset folder: `mis_mascotas`, "Disallow public ID" activado → Guardar.
3. Pon el cloud name y el nombre del preset en `lib/services/cloudinary_service.dart`.

> El **API Secret** de Cloudinary no se usa ni se pone en el código.

## 3. Ejecutar

```bash
flutter pub get
flutter run -d chrome
```

## Prueba de validación / error controlado (para el Word)

- Intentar guardar una mascota con campos vacíos o edad "abc" → el formulario muestra el error.
- Guardar sin imagen → mensaje "Selecciona una imagen para la mascota."
- Login con contraseña incorrecta → "Correo o contraseña incorrectos."
- Registrar un correo ya existente → "Ese correo ya está registrado."
