# Research: Username en Burbujas de Chat

**Feature**: 002-username-chat-bubbles  
**Date**: 2026-05-08  
**Status**: Complete — todos los NEEDS CLARIFICATION resueltos

---

## Findings

### 1. Estado actual del modelo `ChatMessage`

**Decision**: No se requieren cambios al modelo de datos.  
**Rationale**: `ChatMessage` ya almacena `senderId` (Firebase UID anónimo) y `senderName` (nombre visible del usuario). Firestore persiste estos campos en cada documento. El campo ya es enviado correctamente desde `ChatService.sendMessage()`.  
**Alternatives considered**: Añadir un campo `isOwn` al modelo — rechazado porque `isOwn` es relativo a cada cliente (lo que es "propio" para un usuario es "recibido" para otro), por lo que no puede persistirse en Firestore.

---

### 2. Identificación "mensaje propio vs recibido"

**Decision**: Comparar `msg.senderId == currentUser.uid` en `ChatController` (comportamiento actual — sin cambios).  
**Rationale**: Cada sesión de navegador genera un `uid` único de Firebase Anonymous Auth. Aunque dos pestañas usen el mismo nombre de pantalla, sus `uid` son distintos, por lo que la distinción de "propio" es siempre correcta.  
**Alternatives considered**: Usar una clave de sesión generada en el cliente (e.g., UUID en `localStorage`) — descartado porque Firebase Anonymous Auth ya provee un identificador persistente y seguro.

---

### 3. Dónde mostrar el nombre del remitente (gap actual)

**Decision**: Mostrar `senderName` encima de **todas** las burbujas, tanto propias como ajenas.  
**Rationale**:
- Actualmente `chat_catalog.dart` solo muestra el nombre cuando `isOwn == false` (condición `if (!isOwn)`).
- La feature solicita que el nombre sea visible en cada burbuja para que al abrir dos pestañas cualquier observador pueda identificar quién dijo qué.
- Mostrar el propio nombre en la burbuja propia también confirma visualmente la identidad con la que se ingresó al chat.  
**Alternatives considered**:
  - Mostrar "Tú" para mensajes propios en lugar del nombre real — rechazado porque no ayuda cuando se tienen dos pestañas con diferentes nombres y se quiere confirmar con cuál nombre se envió.
  - No mostrar nombre en burbujas propias — es la situación actual, que es el bug/gap a corregir.

---

### 4. Estilo del nombre en burbujas propias

**Decision**: El nombre en burbujas propias se muestra alineado a la derecha, con el mismo estilo tipográfico que el nombre en burbujas ajenas (gris, 11px, semi-bold), pero sin `padding left` — usando `padding right: 4` en su lugar.  
**Rationale**: Mantener consistencia visual. El usuario reconocerá la convención: nombre sobre burbuja, siempre.  
**Alternatives considered**: Color diferente para el nombre propio (e.g., azul) — posible en el futuro, pero innecesario para este scope.

---

### 5. System prompt fragment de GenUI

**Decision**: Actualizar `kChatBubbleSystemPromptFragment` para que el LLM sepa que ahora debe mostrar `senderName` en **todos** los casos, no solo cuando `isOwn` es false.  
**Rationale**: El fragmento de prompt guía al modelo generativo; si no se actualiza, el modelo podría omitir el nombre en burbujas propias cuando regenera la UI.  
**Alternatives considered**: No actualizar el prompt — rechazado porque causaría inconsistencias si el LLM regenera la superficie.

---

### 6. Archivos afectados

| Archivo | Cambio necesario |
|---|---|
| `app/lib/features/chat/catalog/chat_catalog.dart` | Eliminar condición `if (!isOwn)` que oculta nombre; ajustar padding para burbujas propias |
| Ningún otro archivo | Sin cambios en modelo, servicios, rutas ni tests existentes |

---

## Conclusión

El cambio es **mínimo y quirúrgico**: una sola modificación en `chat_catalog.dart`. No hay NEEDS CLARIFICATION pendientes. Todos los pilares de infraestructura (Firestore, Anonymous Auth, genui surfaces) ya soportan la feature.
