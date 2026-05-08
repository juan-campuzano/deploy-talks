# Research: Flutter Web Chat con Firebase y gen_ui

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08  
**Status**: Complete — todos los NEEDS CLARIFICATION resueltos

---

## 1. Paquete `genui` — Rol y Modelo de Integración

**Decision**: `genui ^0.9.0` se usa para renderizar las **respuestas del asistente IA** como superficies de UI generadas dinámicamente. Los mensajes de texto del usuario se muestran con widgets Flutter estándar.

**Rationale**:  
`genui` no es un widget de burbuja de chat convencional. Es un framework que:
1. Recibe chunks de texto de un LLM (stream).
2. Parsea instrucciones A2UI embebidas en el stream via `A2uiParserTransformer`.
3. Instancia widgets Flutter del catálogo (`CoreCatalogItems` + catalog personalizado) en superficies (`Surface`) controladas por `SurfaceController`.
4. Maneja estado reactivo via `DataModel` — los widgets se reconstruyen solo cuando su dato cambia.

El patrón de integración en el chat es:
- Cada mensaje de usuario se envía a Firestore (persistencia) Y a la `Conversation` (genui).
- La respuesta del LLM llega en stream → `A2uiTransportAdapter.addChunk()` → superficie generada.
- Cada superficie del LLM se renderiza como una "burbuja" IA usando `Surface(host: conversation.host, surfaceId: id)`.

**Alternatives considered**:
- `flutter_chat_ui` (bubble UI clásica): Descartado porque no soporta generación dinámica de widgets por IA.
- Custom `StreamBuilder` con Markdown: Descartado porque no permite a genui crear widgets interactivos como botones, campos de texto u otros componentes ricos.

---

## 2. Backend LLM para `genui` — Firebase Vertex AI

**Decision**: Usar `firebase_vertexai` como adaptador LLM dentro del `onSend` callback de `A2uiTransportAdapter`.

**Rationale**:
- `genui` es agnóstico al backend LLM; requiere solo implementar el callback `onSend` que alimenta chunks al transporte.
- `firebase_vertexai` se integra nativamente con el proyecto Firebase existente, comparte las reglas de seguridad y credenciales, y soporta streaming.
- Alternativa `google_generative_ai` (Gemini directo) requeriría exponer una API key en el cliente web (riesgo de seguridad). `firebase_vertexai` delega la autenticación a Firebase Auth.

**Implementation pattern**:
```dart
// En genui_service.dart
Future<void> _onSendToLLM(ChatMessage message) async {
  final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash');
  final response = model.generateContentStream([Content.text(message.text)]);
  await for (final chunk in response) {
    _transport.addChunk(chunk.text ?? '');
  }
}
```

**Alternatives considered**:
- `google_generative_ai` con API key en `.env`: Descartado por exposición de credenciales en web build.
- Backend proxy (Cloud Functions): Descartado por overhead innecesario en v1; `firebase_vertexai` es suficiente.

---

## 3. Firebase Firestore — Estructura de mensajes

**Decision**: Colección `messages` plana en Firestore con campos `senderId`, `senderName`, `text`, `timestamp`, `roomId`. Los mensajes se leen en tiempo real via `snapshots()`.

**Rationale**:
- Una sala pública en v1 simplifica el modelo (un solo `roomId = 'public'`).
- `snapshots()` de Firestore ofrece sincronización en tiempo real nativa, compatible con `StreamBuilder` en Flutter web.
- Ordenar por `timestamp` con índice compuesto `(roomId, timestamp)` cubre la query más común.

**Firestore path**: `messages/{messageId}` (colección raíz en v1)

**Alternatives considered**:
- Subcolecciones `rooms/{roomId}/messages`: Preferida para multi-sala, pero over-engineering para v1 con sala única.
- Firebase Realtime Database: Descartado; Firestore tiene mejor soporte de queries complejas y reglas de seguridad expresivas.

---

## 4. Identificación de Usuario — Solo Nombre de Usuario

**Decision**: No se usa Firebase Authentication. El usuario ingresa un nombre de usuario libre al abrir la app. Ese nombre se guarda en memoria de sesión (`ValueNotifier<String?>`) y se usa como `senderName` en los mensajes. Firebase Anonymous Auth se activa en segundo plano para que las Firestore Security Rules puedan verificar `request.auth != null`.

**Rationale**:
- Simplicidad máxima para el usuario: cero formularios de registro, cero contraseñas.
- Firebase Anonymous Auth es invisible para el usuario pero permite mantener reglas de seguridad básicas en Firestore (usuarios autenticados anónimamente pueden leer/escribir; usuarios sin sesión no).
- El `uid` del usuario anónimo se genera automáticamente por Firebase y se usa como `senderId` en los documentos de Firestore.
- La identidad (nombre elegido) no persiste entre sesiones del navegador — comportamiento aceptado y documentado en Assumptions.

**Implementation pattern**:
```dart
// Al confirmar el nombre de usuario:
final credential = await FirebaseAuth.instance.signInAnonymously();
// credential.user!.uid → usado como senderId en Firestore
// nombre elegido → guardado en ValueNotifier<String?> _usernameNotifier
```

**Alternatives considered**:
- Email/contraseña: Más robusto pero innecesariamente complejo para el objetivo de la demo.
- Sin ninguna auth (Firestore abierto): Descartado por riesgo de seguridad — cualquier cliente podría escribir/leer sin restricción.
- Persistir nombre en `localStorage` via `shared_preferences`: Viable pero agrega complejidad; en v1 el flujo sin persistencia es aceptable y más simple.

---

## 5. Gestión de Estado — Provider / ChangeNotifier

**Decision**: `ChangeNotifier` + `Provider` para estado local de pantallas. Sin gestor de estado global complejo en v1.

**Rationale**:
- Flutter 3.x incluye soporte nativo para `ChangeNotifier`. No se necesita Riverpod/Bloc para la complejidad de esta app en v1.
- `ChatController` maneja la lista de `surfaceIds` de genui y la lógica de scroll.
- `AuthController` maneja el estado de autenticación y errores de login/registro.

**Alternatives considered**:
- Riverpod: Mejor para apps más complejas; over-engineering para v1.
- Bloc: Mayor boilerplate sin beneficio en este scope.

---

## 6. Routing — go_router

**Decision**: `go_router ^14.x` con guard de autenticación via `redirect`.

**Routes**:
- `/login` — LoginPage (accesible sin auth)
- `/chat` — ChatPage (protegida, redirige a `/login` si no autenticado)
- `/` → redirige a `/chat` si autenticado, `/login` si no

**Rationale**: `go_router` es el router oficial recomendado por Flutter team y maneja correctamente el historial del navegador web.

---

## 7. Catálogo `genui` personalizado — Chat Bubble

**Decision**: Crear un `CatalogItem` llamado `ChatBubble` que el LLM puede usar para generar burbujas IA con campos `content` (texto), `type` (e.g., "assistant"), y `timestamp`.

**Rationale**: `CoreCatalogItems` incluye widgets genéricos (Text, Image, Button, etc.). Para que las respuestas IA se vean como burbujas de chat diferenciadas visualmente, se define un `ChatBubble` catalog item con estilo propio. El system prompt del LLM instruye explícitamente a usar `ChatBubble` para cada respuesta.

**Schema**:
```json
{
  "content": "string (el texto de la respuesta)",
  "type": "string (siempre 'assistant')",
  "senderName": "string (nombre del asistente)"
}
```

---

## 8. Sincronización Firebase ↔ genui — Diseño de flujo (Opción B: todas las burbujas via gen_ui)

**Decision**: Cada mensaje que llega desde Firestore (propio o ajeno) se envía al LLM vía `gen_ui` para que genere la burbuja visualmente. **No se usan widgets Flutter estándar para burbujas** — todo pasa por `Surface(gen_ui)`.

**Flujo por mensaje**:
1. Firestore emite un nuevo `ChatMessage` vía `snapshots()`.
2. El cliente verifica si ya existe una superficie `gen_ui` para ese `messageId` (evita duplicados en re-renders).
3. Si no existe, construye un prompt con el contexto del mensaje y llama `conversation.sendRequest()` (o crea una superficie directamente vía `SurfaceController` con un A2UI pre-construido para evitar latencia del LLM en mensajes propios).
4. El LLM responde con el widget `ChatBubble` apropiado (estilo derecha/izquierda según `isOwn`).
5. La superficie se añade al `ListView` del chat.

**Estrategia para reducir latencia**:
- Mensajes **propios** (recién enviados): se puede crear la superficie `gen_ui` localmente con un A2UI pre-construido (sin esperar respuesta LLM) para respuesta inmediata.
- Mensajes **ajenos** (llegados de Firestore): siempre pasan por el LLM para máxima variedad visual.

**Rationale**:
- Permite al LLM variar el estilo visual de cada burbuja (colores, tamaños, énfasis) según el contenido del mensaje.
- Mantiene el uso completo de `gen_ui` como fue solicitado originalmente.
- Los mensajes se siguen persistiendo en Firestore para historial entre sesiones.

**Implicaciones de costo**:
- Cada mensaje entrante genera una llamada al LLM (Vertex AI). Para una demo/presentación con tráfico bajo, es aceptable. Para producción a escala, se debe monitorear el uso.

**Alternatives considered**:
- Usar `SurfaceController` directamente sin LLM (A2UI hardcoded): Más rápido y barato, pero pierde la variedad visual generativa que es el punto central del feature.
- Mezclar: burbujas propias sin LLM + ajenas con LLM: Viable como optimización futura.

---

## Resolución de NEEDS CLARIFICATION

| Item | Resolución |
|------|-----------|
| LLM provider para genui | `firebase_vertexai` (Gemini 2.0 Flash) — seguro en web, integrado con Firebase Auth |
| Todas las burbujas via gen_ui | Cada mensaje (propio y ajeno) genera una Surface gen_ui; no hay widgets de burbuja Flutter estándar |
| Persistencia de mensajes | Mensajes de usuario en Firestore (texto + metadatos); superficies gen_ui son efímeras en sesión |
| Estructura Firestore | Colección plana `messages/` con `roomId = 'public'` para v1 |
| State management | `ChangeNotifier` + `Provider`; sin Riverpod/Bloc en v1 |
| Router | `go_router` con redirect basado en presencia de nombre de usuario en memoria |
| Catálogo genui | `ChatBubble` CatalogItem personalizado + `CoreCatalogItems`; recibe `isOwn` para diferenciación visual |
| Identificación de usuario | Nombre libre + Firebase Anonymous Auth en segundo plano (sin registro, sin contraseña) |
