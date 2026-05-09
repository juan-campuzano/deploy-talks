# Quickstart: Admin Panel

**Feature**: 003-admin-panel  
**Date**: 2026-05-08  
**Audience**: Desarrollador implementando esta feature

---

## Contexto

Esta feature añade un panel de administración en `/admin` a la app Flutter existente. El panel es accesible únicamente con una contraseña configurada en tiempo de build y permite: limpiar el chat, ver usuarios conectados en tiempo real, y generar un background con IA.

---

## Paso 1: Configurar la contraseña de administrador

La contraseña se define como `dart-define` al compilar. **Nunca commitear la contraseña al repositorio.**

```bash
# Desarrollo local
flutter run --dart-define=ADMIN_PASSWORD=tu_contraseña_secreta

# Build web para producción
flutter build web --dart-define=ADMIN_PASSWORD=tu_contraseña_secreta

# VS Code: agregar en launch.json
{
  "args": ["--dart-define=ADMIN_PASSWORD=tu_contraseña_secreta"]
}
```

Acceso en código:
```dart
const adminPassword = String.fromEnvironment('ADMIN_PASSWORD', defaultValue: '');
```

> **Nota**: Si `ADMIN_PASSWORD` está vacío (no se pasó `--dart-define`), el panel de login estará deshabilitado (no se podrá autenticar).

---

## Paso 2: Actualizar `firestore.rules`

Añadir permiso de lectura/escritura para la colección `settings`:

```
match /settings/{docId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

> La validación de que solo el admin escribe se hace en el cliente. Esto es aceptable para un demo personal.

---

## Paso 3: Estructura de archivos a crear

```
app/lib/
├── features/
│   └── admin/
│       ├── admin_login_page.dart       # Pantalla de login con contraseña
│       ├── admin_dashboard_page.dart   # Panel principal de admin
│       ├── admin_session_notifier.dart # ValueNotifier<bool> para auth state
│       └── widgets/
│           ├── connected_users_card.dart  # Lista de usuarios conectados
│           ├── clear_chat_card.dart       # Botón de limpiar chat
│           └── background_prompt_card.dart # Input de prompt + generación
├── models/
│   ├── chat_background.dart    # Nuevo modelo
│   └── presence_record.dart    # Nuevo modelo (extiende datos de presence)
└── services/
    └── admin_service.dart      # Nuevo servicio (clear + background)
```

**Archivos modificados**:
- `lib/router.dart` — añadir ruta `/admin` con guard
- `lib/main.dart` — añadir `AdminSessionNotifier` y `AdminService` como Providers
- `lib/services/presence_service.dart` — añadir `connectedUsersStream()`
- `lib/features/chat/chat_page.dart` — escuchar `backgroundStream()` para aplicar el fondo
- `firestore.rules` — añadir regla para `settings`

---

## Paso 4: Registro en el router

```dart
// En router.dart
GoRouter buildRouter(UserNotifier userNotifier, AdminSessionNotifier adminNotifier) {
  return GoRouter(
    initialLocation: '/enter-name',
    refreshListenable: Listenable.merge([userNotifier, adminNotifier]),
    redirect: _buildRedirect(userNotifier, adminNotifier),
    routes: [
      // ... rutas existentes ...
      GoRoute(
        path: '/admin',
        builder: (context, state) => adminNotifier.value
            ? const AdminDashboardPage()
            : AdminLoginPage(adminNotifier: adminNotifier),
      ),
    ],
  );
}
```

---

## Paso 5: Navegación al panel

La URL `/admin` no aparece en la UI del chat. Para acceder:
- Navegar directamente a `http://localhost:PORT/#/admin` (web)
- O añadir un atajo temporal durante desarrollo

---

## Paso 6: Cómo funciona el background en tiempo real

1. `AdminService.generateBackground(prompt)` escribe en `settings/chat_background`
2. `ChatPage` escucha `AdminService.backgroundStream()` (nuevo `StreamBuilder`)
3. El `Scaffold` / `Container` raíz de `ChatPage` usa el background actual del stream
4. Todos los clientes reciben la actualización automáticamente via Firestore streaming

---

## Valores por defecto

| Entidad | Valor por defecto |
|---------|-----------------|
| Background | `null` (sin fondo personalizado → `ThemeData` del sistema) |
| Contraseña admin | `''` (panel deshabilitado si no se pasa `--dart-define`) |
| Batch delete | Hasta 500 docs por batch, múltiples batches si es necesario |

---

## Probar la feature

```bash
# 1. Correr con contraseña de admin
flutter run -d chrome --dart-define=ADMIN_PASSWORD=test123

# 2. Abrir en navegador: http://localhost:PORT/#/admin
# 3. Ingresar "test123" → acceso al panel

# 4. Verificar:
#    - Lista de usuarios conectados (abrir otra pestaña con nombre)
#    - Limpiar chat (enviar mensajes, luego limpiar)
#    - Cambiar background (escribir "fondo azul oceánico" y confirmar)
```
