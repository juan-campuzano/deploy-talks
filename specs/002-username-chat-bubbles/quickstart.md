# Quickstart: Username en Burbujas de Chat

**Feature**: 002-username-chat-bubbles  
**Branch**: `002-username-chat-bubbles`

---

## Cambio a implementar

Un solo archivo a modificar: `app/lib/features/chat/catalog/chat_catalog.dart`

### ¿Qué cambia?

**Antes**: El nombre del remitente (`senderName`) solo se muestra en burbujas ajenas (`isOwn == false`).  
**Después**: El nombre del remitente se muestra en **todas** las burbujas (propias y ajenas).

---

## Diff conceptual

```dart
// ANTES — en widgetBuilder del ChatBubble catalog item:
if (!isOwn)
  Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 2),
    child: Text(senderName, style: ...),
  ),

// DESPUÉS:
Padding(
  padding: EdgeInsets.only(
    left: isOwn ? 0 : 4,
    right: isOwn ? 4 : 0,
    bottom: 2,
  ),
  child: Text(senderName, style: ...),
),
```

También actualizar `kChatBubbleSystemPromptFragment`:

```dart
// ANTES:
// - When isOwn is false: align the bubble to the LEFT, use a grey background, and show the senderName above the text.

// DESPUÉS:
// - When isOwn is false: align the bubble to the LEFT and use a grey background.
// - Always show the senderName above the bubble text, regardless of isOwn.
```

---

## Pasos de verificación manual

1. Ejecutar la app en modo web: `flutter run -d chrome` (desde `app/`)
2. Abrir **dos pestañas** del navegador con `localhost:PORT`
3. En la pestaña A, ingresar nombre "Ana" → enviar un mensaje
4. En la pestaña B, ingresar nombre "Luis" → enviar un mensaje
5. **Verificar en pestaña A**: La burbuja de Ana (derecha, azul) muestra "Ana" arriba; la burbuja de Luis (izquierda, gris) muestra "Luis" arriba
6. **Verificar en pestaña B**: La burbuja de Luis (derecha, azul) muestra "Luis" arriba; la burbuja de Ana (izquierda, gris) muestra "Ana" arriba

---

## Criterios de aceptación rápida

- [ ] Toda burbuja (propia y ajena) tiene el nombre del remitente visible
- [ ] El nombre en burbujas propias está alineado a la derecha
- [ ] El nombre en burbujas ajenas está alineado a la izquierda
- [ ] Los mensajes históricos cargados al abrir el chat también muestran el nombre
- [ ] No hay regresiones en la alineación ni los colores de las burbujas

---

## Notas

- No hay cambios de esquema en Firestore
- No se necesitan migraciones de datos
- Los mensajes existentes ya tienen `senderName` almacenado
