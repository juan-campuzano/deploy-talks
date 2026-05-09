# Data Model: Username en Burbujas de Chat

**Feature**: 002-username-chat-bubbles  
**Date**: 2026-05-08

---

## Entities

### `ChatMessage` (sin cambios de esquema)

Almacenado en Firestore — colección `messages`.

| Campo | Tipo | Descripción | Estado |
|---|---|---|---|
| `id` | `String` | ID de documento Firestore (auto-generado) | Existente |
| `senderId` | `String` | UID de Firebase Anonymous Auth del remitente | Existente |
| `senderName` | `String` | Nombre visible ingresado por el usuario | Existente |
| `text` | `String` | Contenido del mensaje | Existente |
| `timestamp` | `DateTime` | Marca de tiempo de creación | Existente |
| `roomId` | `String` | Sala del chat (siempre `'public'` por ahora) | Existente |

**Validaciones**:
- `senderName` no puede ser vacío (validado en `EnterNamePage` antes de llegar al chat).
- `senderId` es asignado automáticamente por Firebase Auth — nunca vacío.

**Conclusión**: El esquema de `ChatMessage` no requiere cambios. Los datos necesarios para mostrar el nombre en la burbuja ya están presentes.

---

### `AppUser` (sin cambios)

Estado en memoria, no persistido en Firestore.

| Campo | Tipo | Descripción |
|---|---|---|
| `uid` | `String` | UID de Firebase Anonymous Auth |
| `displayName` | `String` | Nombre visible del usuario actual |

---

### `ChatBubble` (componente GenUI — cambio de comportamiento)

Superficie renderizada por el motor genui. Su esquema de datos **no cambia**; lo que cambia es la lógica de presentación en el `widgetBuilder`.

| Prop | Tipo | Descripción |
|---|---|---|
| `content` | `String` | Texto del mensaje |
| `senderName` | `String` | Nombre del remitente |
| `isOwn` | `bool` | `true` si el mensaje pertenece al usuario actual |

**Cambio de comportamiento (presentación)**:

| Estado actual | Estado objetivo |
|---|---|
| `senderName` solo visible cuando `isOwn == false` | `senderName` visible para **todos** los mensajes |
| Nombre alineado a la izquierda para mensajes ajenos | Nombre alineado a la derecha para mensajes propios, izquierda para ajenos |

---

## Diagrama de flujo de datos

```
EnterNamePage
  └─ UserNotifier.setUser(displayName)
        └─ AppUser { uid, displayName }
              └─ ChatController
                    └─ msg.senderId == currentUser.uid → isOwn
                    └─ GenuiService.renderMessageAsBubble(msg, isOwn)
                          └─ ChatBubble { content, senderName, isOwn }
                                └─ Widget: nombre visible siempre ← CAMBIO
```

---

## Notas de migración

No hay migración de datos necesaria. Los documentos existentes en Firestore ya contienen `senderName`. Los mensajes históricos mostrarán el nombre del remitente automáticamente tras el despliegue del cambio de UI.
