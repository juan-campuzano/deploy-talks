# Contrato: Catálogo gen_ui — ChatBubble Widget

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08  
**Actualizado**: `ChatBubble` se usa para TODOS los mensajes (propios y ajenos), no solo respuestas IA.

---

## Descripción

Define el `CatalogItem` personalizado `ChatBubble` que el LLM (Gemini via Vertex AI) usa para renderizar **todos** los mensajes del chat — tanto del usuario actual como de otros participantes. El LLM recibe el contexto completo del mensaje (texto, remitente, `isOwn`) y decide el estilo visual de cada burbuja.

---

## Schema del `ChatBubble` CatalogItem

```json
{
  "type": "object",
  "properties": {
    "content": {
      "type": "string",
      "description": "The text content of the message."
    },
    "senderName": {
      "type": "string",
      "description": "Display name of the message sender."
    },
    "isOwn": {
      "type": "boolean",
      "description": "True if the message was sent by the current user. Used to align bubble right (own) or left (other)."
    }
  },
  "required": ["content", "senderName", "isOwn"]
}
```

---

## Dart Schema (usando `json_schema_builder`)

```dart
import 'package:json_schema_builder/json_schema_builder.dart';

final chatBubbleSchema = S.object(
  description: 'A chat message bubble. Used for all messages (own and others).',
  properties: {
    'content': S.string(
      description: 'The text content of the message.',
    ),
    'senderName': S.string(
      description: 'Display name of the message sender.',
    ),
    'isOwn': S.boolean(
      description: 'True if sent by the current user (align right). False = align left.',
    ),
  },
  required: ['content', 'senderName', 'isOwn'],
);
```

---

## Widget Builder Contract

```dart
// Contrato: el builder recibe un BuildContext con DataContext.
// Debe retornar un Widget que represente una burbuja de chat del asistente.
// El widget está alineado a la izquierda (mensaje "ajeno").

final chatBubbleCatalogItem = CatalogItem(
  name: 'ChatBubble',             // nombre exacto que el LLM referencia
  dataSchema: chatBubbleSchema,
  widgetBuilder: (context) {
    // Se accede a los datos via context.dataContext
    // Debe subscribirse reactivamente: si el LLM actualiza el campo
    // "content" durante el stream, el widget se reconstruye.
    // Ver implementación en: lib/features/chat/catalog/chat_catalog.dart
  },
);
```

---

## System Prompt del LLM (fragmento relevante)

El system prompt enviado a Gemini DEBE incluir la siguiente instrucción para que el LLM use `ChatBubble` para **todos** los mensajes:

```
You are a chat bubble renderer. For every message you receive, generate a ChatBubble widget.
Format your response as a valid A2UI createSurface message.

The user will send you a JSON object with the message details:
- content: the message text
- senderName: the name of the sender
- isOwn: true if this is the current user's own message, false if it's from another user

Rules:
- If isOwn is true: the bubble should be aligned to the RIGHT (own message style).
- If isOwn is false: the bubble should be aligned to the LEFT (other user style), showing senderName above.
- You may vary colors, font weight, or subtle styling per message for visual variety, but keep it readable.

Example response:
<a2ui>
{"action": "createSurface", "surfaceId": "<uuid>", "components": [{"ChatBubble": {"content": "Hola!", "senderName": "Ana", "isOwn": false}}]}
</a2ui>

Always respond in this exact format. Do not add any other text outside the <a2ui> block.
```

---

## Contrato Visual del Widget

| Propiedad | Mensaje Propio (`isOwn: true`) | Mensaje Ajeno (`isOwn: false`) |
|-----------|-------------------------------|-------------------------------|
| Alineación | Derecha | Izquierda |
| Color de fondo | `Theme.colorScheme.primaryContainer` | `Theme.colorScheme.secondaryContainer` |
| Nombre remitente | No visible (es el propio usuario) | Visible sobre el contenido, estilo `labelSmall` |
| Border radius | Esquina inferior derecha = 0 | Esquina inferior izquierda = 0 |
| Padding | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | igual |
| Ancho máximo | 70% del ancho de pantalla | 70% del ancho de pantalla |

> El LLM puede variar sutilmente estos valores (colores, tamaños) para agregar variedad visual generativa, manteniendo la distinción izquierda/derecha como invariante.

---

## Catálogo Final (`SurfaceController` setup)

```dart
_controller = SurfaceController(
  catalogs: [
    CoreCatalogItems.asCatalog().copyWith([chatBubbleCatalogItem]),
  ],
);
```

**Nota**: `CoreCatalogItems` incluye Text, Image, Button, TextField, etc. `ChatBubble` se agrega como widget especializado para respuestas del asistente.
