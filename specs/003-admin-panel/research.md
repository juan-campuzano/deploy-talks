# Research: Admin Panel

**Feature**: 003-admin-panel  
**Date**: 2026-05-08  
**Status**: Complete — todas las incógnitas resueltas

---

## 1. Autenticación del Administrador

**Decision**: Contraseña como constante en tiempo de compilación vía `--dart-define`

**Rationale**: El proyecto es una demo personal sin backend propio. La autenticación de un único administrador con contraseña fija no requiere un sistema de tokens complejos. Almacenar la contraseña como `const String.fromEnvironment('ADMIN_PASSWORD')` con `--dart-define` en tiempo de build es el equilibrio correcto entre seguridad, simplicidad y despliegue rápido. En Flutter Web el JS compilado incluye la contraseña ofuscada en release mode; para un demo personal esto es aceptable.

**Alternatives considered**:
- Firebase Auth con email/password: requiere crear un usuario en Firebase Console; añade dependencia de Auth para el admin (ya existe Anonymous Auth). Rechazado por complejidad innecesaria para un solo admin.
- Contraseña hasheada en Firestore: requiere reglas de seguridad complejas para que solo el admin lea el hash, y una Cloud Function para validar sin exponer. Sobreingeniería para demo.
- Firebase Remote Config: permite cambiar la contraseña sin rebuild, pero añade dependencia nueva y latencia de red. Rechazado.

**Security note**: La sesión admin es exclusivamente in-memory (`AdminSessionNotifier`). Navegar a `/admin` sin autenticar muestra la pantalla de login. El estado se pierde al cerrar/recargar la app, lo que es el comportamiento deseable para una demo pública.

---

## 2. Limpieza del Chat

**Decision**: Batch delete de Firestore desde el cliente con operaciones batch (máx 500 docs por batch)

**Rationale**: La colección `messages` usa `roomId: 'public'`. Firestore permite eliminar hasta 500 documentos en un solo batch. Para un chat de demo la colección rara vez superará ese límite; si lo supera, se ejecutan múltiples batches secuenciales. No se requiere Cloud Function para este caso.

**Alternatives considered**:
- Cloud Function con `deleteCollection` helper: más robusto para millones de docs, pero añade complejidad de despliegue. Rechazado para demo de bajo volumen.
- Marcar mensajes como `deleted: true` (soft delete): requiere actualizar las queries existentes. Rechazado por impacto en código existente.

---

## 3. Lista de Usuarios Conectados (Presence)

**Decision**: Extender `PresenceService` con `connectedUsersStream()` que retorna `Stream<List<PresenceRecord>>`

**Rationale**: La colección `presence` ya existe y es populada por `PresenceService.join()`. Actualmente solo `activeCountStream()` está implementado. Añadir `connectedUsersStream()` que mapea los documentos completos es trivial y reutiliza la infraestructura existente.

**Alternatives considered**:
- Realtime Database para presencia (mayor robustez con `onDisconnect`): añadiría `firebase_database` como nueva dependencia. La colección Firestore actual es suficiente para el caso de demo. Rechazado.
- Añadir un nuevo servicio `AdminPresenceService`: innecesario, mejor extender el existente.

**Gap identified**: `PresenceService` no tiene un mecanismo de `onDisconnect` automático — si la app se cierra sin llamar `leave()`, el usuario permanece en `presence`. Esto es un issue pre-existente fuera del scope de este feature; el admin panel simplemente muestra lo que hay en Firestore.

---

## 4. Generación de Background con Gemini / Firebase AI

**Decision**: `FirebaseAI.googleAI()` con modelo `gemini-2.0-flash`; prompt estructurado que retorna JSON con colores hexadecimales para `LinearGradient` de Flutter

**Rationale**: `firebase_ai: ^3.11.0` ya es una dependencia del proyecto. La API de texto es `FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash')` con `generateContent([Content.text(prompt)])`. Para el background, usar CSS puro no es idóneo en Flutter; en cambio, pedir a Gemini que devuelva un JSON `{colors: ["#rrggbb", ...], angle: int, label: String}` es confiable y parseable directamente a `LinearGradient` / `BoxDecoration`.

**Gemini prompt template** (enviado al modelo):
```
The user wants a chat background with the following description: "{userPrompt}".
Respond ONLY with a valid JSON object in this exact format, no markdown, no explanation:
{"colors": ["#hexcolor1", "#hexcolor2"], "angle": 135, "label": "Short description"}
- colors: array of 2-4 hex color strings
- angle: rotation in degrees (0-360)  
- label: short human-readable description (max 30 chars, in Spanish)
```

**Alternatives considered**:
- Pedir CSS `linear-gradient()` string: parsear CSS en Flutter es propenso a errores y no tiene soporte nativo. Rechazado.
- Generar imagen con Imagen 3 via Vertex AI: requiere `FirebaseAI.vertexAI()`, mayor costo, latencia > 5s, y almacenamiento de imagen en Cloud Storage. Fuera del scope.
- Usar `gemini-pro`: modelo más pesado y caro que `gemini-2.0-flash` para un JSON simple. Rechazado.

**Parsing strategy**: `jsonDecode(response.text)` con fallback a un gradient predeterminado si el JSON es inválido.

---

## 5. Persistencia y Propagación en Tiempo Real del Background

**Decision**: Documento `settings/chat_background` en Firestore; `ChatPage` escucha el stream

**Rationale**: Firestore ya es la fuente de verdad del chat. Un solo documento `settings/chat_background` es suficiente para sincronizar el background entre todos los clientes. La propagación es automática mediante el stream existente de Firestore.

**Schema del documento**:
```json
{
  "colors": ["#1a1a2e", "#16213e"],
  "angle": 135,
  "label": "Noche oscura",
  "updatedAt": Timestamp,
  "prompt": "fondo oscuro de noche"
}
```

**Alternatives considered**:
- Firebase Realtime Database para menor latencia: añade dependencia nueva. Rechazado; la latencia de Firestore (~1s) es aceptable.
- Firestore collection con historial de backgrounds: permite undo, pero añade complejidad. Rechazado; solo se necesita el estado actual.

---

## 6. Estructura de Rutas del Panel Admin

**Decision**: Ruta `/admin` con `AdminSessionNotifier` como guard en `GoRouter`, independiente del guard de usuario

**Rationale**: El router existente usa `UserNotifier` como `refreshListenable`. Para el admin, se añade `AdminSessionNotifier` (ValueNotifier<bool>) como segundo listenable con `GoRouter`'s `refreshListenable: Listenable.merge([...])`. La ruta `/admin` no requiere que haya un usuario del chat autenticado.

**Alternatives considered**:
- Ruta anidada bajo `/chat/admin`: mezclaría flujos de usuario y admin. Rechazado.
- Pantalla de admin accesible solo via URL directa (sin enlace desde el chat): correcto para seguridad por oscuridad, suficiente para demo.

---

## 7. Dependencias Nuevas

**Decision**: No se añaden dependencias nuevas

**Rationale**: Todas las dependencias necesarias ya están presentes:
- `firebase_ai: ^3.11.0` → Gemini text generation
- `cloud_firestore: ^6.3.0` → batch delete, settings document, presence list
- `go_router: ^17.2.3` → nueva ruta `/admin`
- `provider: ^6.1.5+1` → `AdminSessionNotifier` como Provider

La contraseña se almacena vía `--dart-define`, sin `flutter_dotenv`.
