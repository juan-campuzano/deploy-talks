# Data Model: Flutter Web Chat con Firebase y gen_ui

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08

---

## Entidades del Dominio

### 1. `AppUser`

Representa al participante del chat en la sesión actual. Se construye al confirmar el nombre de usuario en la pantalla de entrada.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `uid` | `String` | ✅ | UID anónimo generado por Firebase Anonymous Auth (invisible para el usuario) |
| `displayName` | `String` | ✅ | Nombre elegido por el usuario al entrar al chat (mínimo 1 carácter, sin espacios laterales) |

**Notas**:
- `AppUser` es un DTO inmutable de sesión; no se persiste en Firestore.
- El `uid` proviene de `FirebaseAuth.instance.currentUser!.uid` tras `signInAnonymously()`.
- El `displayName` se guarda en un `ValueNotifier<AppUser?>` en memoria — se pierde al cerrar o recargar el navegador (comportamiento esperado en v1).

---

### 2. `ChatMessage`

Representa un mensaje enviado por un usuario humano. Se persiste en Firebase Firestore.

| Campo | Tipo Dart | Tipo Firestore | Requerido | Descripción |
|-------|-----------|----------------|-----------|-------------|
| `id` | `String` | `document ID` | ✅ (auto) | ID del documento Firestore (generado por Firestore) |
| `senderId` | `String` | `string` | ✅ | UID del usuario que envió el mensaje |
| `senderName` | `String` | `string` | ✅ | Nombre para mostrar del remitente |
| `text` | `String` | `string` | ✅ | Contenido del mensaje (no vacío) |
| `timestamp` | `DateTime` | `timestamp` | ✅ | Momento de envío (UTC) |
| `roomId` | `String` | `string` | ✅ | Identificador de sala (`'public'` en v1) |

**Reglas de validación**:
- `text.trim().isNotEmpty` — obligatorio, error si está vacío.
- `senderId` debe coincidir con el UID del usuario autenticado activo.
- `timestamp` se establece en el servidor (`FieldValue.serverTimestamp()`) para consistencia.

**Firestore path**: `messages/{messageId}`

---

### 3. `ChatRoom` *(implícito en v1)*

En v1 existe una única sala pública. No tiene documento propio en Firestore; el `roomId = 'public'` es un valor hardcoded que actúa como discriminador en las queries.

| Campo | Valor en v1 |
|-------|-------------|
| `roomId` | `'public'` |
| `name` | `'Chat General'` |

**Upgrade path**: En v2+, esto se expandiría a una colección `rooms/{roomId}` con metadatos de sala y participantes.

---

### 4. `GenuiSurface` *(en memoria, no persiste)*

Representa la burbuja visual de **cualquier mensaje** (propio o ajeno) renderizada por `gen_ui`. Cada `ChatMessage` recibido desde Firestore tiene exactamente una `GenuiSurface` asociada. Solo existe en memoria durante la sesión.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `surfaceId` | `String` | ID asignado por `gen_ui` al crear la superficie (UUID) |
| `messageId` | `String` | ID del `ChatMessage` de Firestore que originó esta superficie |
| `isOwn` | `bool` | `true` si el mensaje es del usuario actual (afecta el estilo generado por el LLM) |
| `isActive` | `bool` | `true` si la superficie sigue activa; `false` si gen_ui la eliminó |

**Ciclo de vida**:
- Se crea cuando Firestore emite un nuevo `ChatMessage` que aún no tiene superficie asociada.
- El `ChatController` mantiene un `Map<String, String> messageIdToSurfaceId` para evitar crear superficies duplicadas en re-renders.
- Al recargar la página, todas las superficies se pierden y se regeneran desde el historial de Firestore.

---

## Esquema Firestore

### Colección: `messages`

```
messages/
└── {auto-id}/
    ├── senderId:   string       -- UID Firebase Auth
    ├── senderName: string       -- Nombre para mostrar
    ├── text:       string       -- Contenido del mensaje
    ├── timestamp:  timestamp    -- Servidor (FieldValue.serverTimestamp)
    └── roomId:     string       -- "public" en v1
```

**Índice requerido**: Compuesto `(roomId ASC, timestamp ASC)` — necesario para query de historial ordenado.

### Query principal (historial):
```dart
FirebaseFirestore.instance
    .collection('messages')
    .where('roomId', isEqualTo: 'public')
    .orderBy('timestamp', descending: false)
    .limit(500)  // SC-003: hasta 500 mensajes
    .snapshots()
```

---

## Diagrama de Relaciones

```
┌─────────────────────────────────────────────┐
│           Pantalla de Entrada                │
│  Usuario escribe displayName                 │
│       └──► Firebase.signInAnonymously()      │
│            AppUser { uid, displayName }      │
└──────────────────┬──────────────────────────┘
                   │ identifica a
                   ▼
┌─────────────────────────────────────────────┐
│           Firestore: messages/               │
│  ChatMessage {                               │
│    id, senderId ───► AppUser.uid             │
│    senderName, text, timestamp, roomId       │
│  }                                           │
└─────────────────────────────────────────────┘
                   │ cada mensaje recibido (propio o ajeno)
                   ▼
┌─────────────────────────────────────────────┐
│           gen_ui (en memoria)                │
│  Conversation → LLM (Vertex AI)              │
│  └── GenuiSurface { surfaceId, messageId,    │
│                     isOwn }                  │
│       └── Surface widget (ChatBubble)        │
│            ← estilo generado por el LLM      │
└─────────────────────────────────────────────┘
```

---

## Modelo de Estados UI

### Estado de Identificación de Usuario

```
SinNombre (app recién abierta o tras salir del chat)
    │ usuario escribe nombre y confirma
    ▼
ConNombre (nombre disponible en memoria, usuario anónimo de Firebase activo)
    │ usuario sale del chat (tap "Salir")
    ▼
SinNombre
```

### Estado del Chat

```
Loading (cargando historial de Firestore)
    │ historial cargado → generar superficie gen_ui por cada mensaje
    ▼
Idle (esperando input del usuario)
    │ usuario envía mensaje
    ▼
SendingMessage (guardando en Firestore)
    │ Firestore confirma → snapshot emite el nuevo mensaje
    ▼
RenderingBubble (gen_ui genera la Surface para el nuevo mensaje)
    │ Surface creada
    ▼
Idle

(Paralelo): cada vez que Firestore emite un mensaje ajeno nuevo →
    RenderingBubble → Idle  (independiente del flujo del usuario)
```

### Estado de una Burbuja genui (Surface)

```
Creating (A2UI stream activo, widget construyéndose incrementalmente)
    │ stream completo
    ▼
Complete (widget estático, interacciones habilitadas)
    │ ConversationSurfaceRemoved
    ▼
Removed (eliminada de la lista, widget desmontado)
```

---

## Reglas de Firestore Security

Ver [contracts/firestore-rules.md](contracts/firestore-rules.md) para el detalle completo.

Resumen de reglas para `messages`:
- **Leer**: solo usuarios autenticados.
- **Crear**: solo el propio usuario puede crear mensajes donde `senderId == request.auth.uid`.
- **Actualizar/Eliminar**: no permitido en v1 (mensajes inmutables).
