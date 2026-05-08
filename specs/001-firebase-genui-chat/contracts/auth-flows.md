# Contrato: Flujos de Identificación y Navegación

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08  
**Actualizado**: Simplificado a nombre de usuario — sin email ni contraseña.

---

## Rutas de la Aplicación

| Ruta | Componente | Acceso | Descripción |
|------|-----------|--------|-------------|
| `/` | — | Público | Redirige a `/chat` si hay nombre en sesión, `/enter-name` si no |
| `/enter-name` | `EnterNamePage` | Público | Pantalla de entrada de nombre de usuario |
| `/chat` | `ChatPage` | Requiere nombre | Pantalla principal del chat |

---

## Flujo: Primer Acceso (Sin Nombre)

```
Usuario → GET /  (sin nombre en sesión)
    │
    ▼
router redirect → GET /enter-name
    │
    ▼
Pantalla: campo de texto "¿Cómo te llamas?"
    │ usuario escribe nombre y confirma
    ▼
Validación client-side:
    ├── nombre.trim().isEmpty → mostrar error "Ingresa un nombre"
    └── nombre.trim().isNotEmpty → continuar
    │
    ▼
FirebaseAuth.instance.signInAnonymously()
    │ (invisible para el usuario)
    ▼
userNotifier.value = AppUser(uid: credential.user.uid, displayName: nombre.trim())
    │
    ▼
router.go('/chat')
```

---

## Flujo: Regreso al Chat (Nombre Ya en Sesión)

```
Usuario → GET /  (nombre en sesión)
    │
    ▼
router redirect → GET /chat
    │
    ▼
ChatPage se carga directamente
```

---

## Flujo: Salir del Chat

```
Usuario → [tap "Salir" en ChatPage]
    │
    ▼
userNotifier.value = null
    │
    ▼
FirebaseAuth.instance.signOut()  (limpia sesión anónima)
    │
    ▼
router redirect → GET /enter-name  (guard automático de go_router)
```

---

## Contrato del Guard de Navegación (`router.dart`)

```dart
// La función redirect se invoca en cada navegación.
// Devuelve la ruta de redirección o null si se permite el acceso.
String? _nameGuard(BuildContext context, GoRouterState state) {
  final hasName = userNotifier.value != null;
  final isGoingToEnterName = state.matchedLocation == '/enter-name';

  if (!hasName && !isGoingToEnterName) return '/enter-name';
  if (hasName && isGoingToEnterName) return '/chat';
  return null; // acceso permitido
}
```

**Invariantes**:
- Un usuario sin nombre en sesión NUNCA puede llegar a `/chat`.
- Un usuario con nombre que navega a `/enter-name` es redirigido a `/chat` automáticamente.
- `userNotifier` (tipo `ValueNotifier<AppUser?>`) es la única fuente de verdad para el estado de identificación.

---

## Validaciones de Nombre de Usuario

| Regla | Comportamiento |
|-------|---------------|
| Vacío o solo espacios | Error inline: "Ingresa un nombre para continuar" |
| Longitud mínima | 1 carácter (tras `trim()`) |
| Longitud máxima | 30 caracteres |
| Caracteres permitidos | Cualquier texto Unicode (sin restricciones adicionales en v1) |

---

## Notas

- **Firebase Anonymous Auth** es un detalle de implementación interno. El usuario nunca ve un formulario de login ni sabe que existe Firebase Auth.
- Si `signInAnonymously()` falla (sin conexión), se muestra un error genérico: "No se pudo conectar. Verifica tu conexión a internet."
- El `uid` anónimo no se muestra en la UI; solo se usa internamente como `senderId` en Firestore.

---

## Flujo: Registro de Usuario Nuevo

```
Usuario → GET /login
    │
    ├── [selecciona "Crear cuenta"]
    ▼
Formulario: email + contraseña + confirmar contraseña
    │ validación client-side (email válido, contraseña >= 8 chars)
    ▼
firebase_auth.createUserWithEmailAndPassword(email, password)
    │
    ├── [éxito] → auth.currentUser disponible
    │       └── router.go('/chat')
    │
    └── [error: email-already-in-use]
            └── mostrar error inline en formulario
```

---

## Flujo: Inicio de Sesión (Login)

```
Usuario → GET /login
    │
    ├── [ingresa email + contraseña]
    ▼
firebase_auth.signInWithEmailAndPassword(email, password)
    │
    ├── [éxito] → authStateChanges emite User != null
    │       └── router redirect: GET /chat
    │
    └── [error: wrong-password | user-not-found | invalid-email]
            └── mostrar error "Credenciales incorrectas" (no revelar si usuario existe)
```

---

## Flujo: Cierre de Sesión (Logout)

```
Usuario → [tap "Cerrar sesión" en ChatPage]
    │
    ▼
firebase_auth.signOut()
    │
    ▼
authStateChanges emite null
    │
    ▼
router redirect: GET /login  (guard automático de go_router)
```

---

## Flujo: Acceso Directo a Ruta Protegida (Deep Link)

```
Usuario → GET /chat  (sin sesión activa)
    │
    ▼
go_router redirect callback:
    authStateChanges.value == null?
    │
    ├── [sí] → redirect a /login
    └── [no] → permitir acceso a /chat
```

---

## Contrato del Guard de Autenticación (`router.dart`)

```dart
// Contrato: la función redirect se invoca en cada navegación.
// Devuelve la ruta de redirección o null si se permite el acceso.
String? _authGuard(BuildContext context, GoRouterState state) {
  final isAuthenticated = authNotifier.value; // bool
  final isGoingToLogin = state.matchedLocation == '/login';

  if (!isAuthenticated && !isGoingToLogin) return '/login';
  if (isAuthenticated && isGoingToLogin) return '/chat';
  return null; // acceso permitido
}
```

**Invariantes**:
- Un usuario no autenticado NUNCA puede llegar a `/chat`.
- Un usuario autenticado que navega a `/login` es redirigido a `/chat` automáticamente.
- El `authStateChanges()` stream de Firebase Auth es la fuente única de verdad para el estado de autenticación.

---

## Mensajes de Error de Autenticación

| Código Firebase | Mensaje al Usuario |
|----------------|-------------------|
| `email-already-in-use` | "Ya existe una cuenta con este email." |
| `invalid-email` | "El email no tiene un formato válido." |
| `weak-password` | "La contraseña debe tener al menos 8 caracteres." |
| `wrong-password` | "Credenciales incorrectas. Verifica tu email y contraseña." |
| `user-not-found` | "Credenciales incorrectas. Verifica tu email y contraseña." |
| Cualquier otro | "Ocurrió un error inesperado. Intenta nuevamente." |

> **Nota de seguridad**: `wrong-password` y `user-not-found` muestran el mismo mensaje para no revelar si un email está registrado (prevención de user enumeration).
