# Contrato: Servicio de Administración (`AdminService`)

**Feature**: 003-admin-panel  
**Date**: 2026-05-08

---

## Responsabilidades

`AdminService` encapsula las tres operaciones administrativas que modifican el estado global del chat:

1. Limpiar todos los mensajes del chat
2. Generar y persistir un nuevo background via Gemini
3. Exponer el background activo como stream

---

## Interfaz pública

### `clearChat({String roomId = 'public'}) → Future<void>`

Elimina todos los mensajes de la sala especificada en Firestore usando batch deletes.

**Pre-condiciones**: El admin está autenticado (verificado en la capa de UI)  
**Post-condiciones**: Todos los documentos en `messages` con `roomId == roomId` son eliminados  
**Errores**: Lanza `FirebaseException` si la operación de Firestore falla  
**Comportamiento con chat vacío**: Operación exitosa sin efecto observable  
**Comportamiento con >500 mensajes**: Ejecuta múltiples batches secuenciales hasta eliminar todos

---

### `generateBackground(String userPrompt) → Future<ChatBackground>`

Envía el prompt a Gemini, parsea la respuesta JSON y persiste el resultado en `settings/chat_background`.

**Pre-condiciones**: `userPrompt` no es vacío  
**Post-condiciones**: Documento `settings/chat_background` actualizado en Firestore; retorna el `ChatBackground` creado  
**Errores**:
- `GeminiParseException`: si la respuesta de la IA no es JSON parseable al schema esperado
- `FirebaseException`: si falla la escritura a Firestore
- `FirebaseAIException`: si la llamada a Gemini falla (rate limit, error de red, etc.)

**Prompt enviado a Gemini** (interno):
```
The user wants a chat background with the following description: "{userPrompt}".
Respond ONLY with a valid JSON object in this exact format, no markdown, no explanation:
{"colors": ["#hexcolor1", "#hexcolor2"], "angle": 135, "label": "Short description in Spanish"}
- colors: array of 2 to 4 hex color strings
- angle: rotation in degrees (0-360)
- label: short human-readable description in Spanish (max 30 chars)
```

**Fallback**: Si el JSON es inválido, lanza `GeminiParseException` (no aplica un default silencioso)

---

### `backgroundStream() → Stream<ChatBackground?>`

Stream del background activo. Emite `null` si el documento `settings/chat_background` no existe.

**Comportamiento**: Hot stream; emite el valor actual al suscribirse y cada vez que el documento cambia  
**Errores de Firestore**: propagados al stream caller

---

## Contrato: `AdminSessionNotifier`

`ValueNotifier<bool>` que expone si el admin está autenticado en memoria.

### `authenticate(String password) → bool`

Compara la contraseña ingresada con la constante `ADMIN_PASSWORD` de compile-time.

**Retorna**: `true` si la contraseña es correcta y actualiza `value = true`; `false` si es incorrecta  
**Nota de seguridad**: Comparación directa de strings (no timing-safe); aceptable para demo personal

### `logout() → void`

Establece `value = false`.

---

## Contrato: `PresenceService` (extensión)

### `connectedUsersStream() → Stream<List<PresenceRecord>>`

Stream de todos los usuarios actualmente en la colección `presence`, ordenados por `joinedAt` ascendente.

**Emite**: Lista vacía si no hay usuarios conectados  
**Errores de Firestore**: propagados al stream caller

---

## Contrato: Documento Firestore `settings/chat_background`

```jsonc
// Colección: settings
// Documento: chat_background
{
  "colors": ["#1a1a2e", "#16213e"],   // array de 2-4 hex strings
  "angle": 135,                        // int 0-360
  "label": "Noche galáctica",          // string max 30 chars
  "prompt": "fondo oscuro galaxia",    // string original del admin
  "updatedAt": "2026-05-08T..."        // Firestore Timestamp
}
```

**Reglas de Firestore** (a agregar en `firestore.rules`):
- Lectura: permitida para todos los usuarios autenticados (anónimos incluidos)
- Escritura: solo desde la aplicación cliente (no hay regla de "solo admin" en Firestore ya que la validación es en el cliente)

---

## Contrato: `ChatBackground` (modelo Dart)

```dart
class ChatBackground {
  final List<String> colors;   // 2-4 hex strings
  final int angle;             // 0-360
  final String label;          // max 30 chars
  final String prompt;         // prompt original
  final DateTime updatedAt;
}
```

**Factory**: `ChatBackground.fromFirestore(DocumentSnapshot)`  
**Serialización**: `toMap() → Map<String, dynamic>` (para escritura a Firestore)

---

## Contrato: Ruta del Panel Admin

| Ruta | Comportamiento |
|------|----------------|
| `/admin` | Si `AdminSessionNotifier.value == false` → muestra `AdminLoginPage`; si `true` → muestra `AdminDashboardPage` |
| Cualquier otra ruta | No muestra ningún acceso al panel de admin |

**GoRouter redirect**: `AdminSessionNotifier` se añade como segundo listenable en `Listenable.merge([userNotifier, adminSessionNotifier])`.
