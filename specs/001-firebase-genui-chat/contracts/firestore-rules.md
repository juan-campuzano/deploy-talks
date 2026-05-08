# Contrato: Firebase Firestore Security Rules

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08

---

## Reglas de Seguridad (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── messages ──────────────────────────────────────────────────────────
    // Colección raíz de mensajes del chat.
    match /messages/{messageId} {

      // Leer: solo usuarios autenticados pueden leer mensajes.
      allow read: if request.auth != null;

      // Crear: solo el usuario autenticado puede crear mensajes
      // donde senderId coincide con su propio UID.
      allow create: if request.auth != null
                    && request.resource.data.senderId == request.auth.uid
                    && request.resource.data.text is string
                    && request.resource.data.text.size() > 0
                    && request.resource.data.text.size() <= 2000
                    && request.resource.data.roomId is string
                    && request.resource.data.senderName is string;

      // Actualizar/Eliminar: no permitido en v1 (mensajes inmutables).
      allow update, delete: if false;
    }

    // ── default deny ──────────────────────────────────────────────────────
    // Cualquier colección no declarada explícitamente está denegada.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Índices Requeridos (`firestore.indexes.json`)

```json
{
  "indexes": [
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "roomId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

**Propósito**: Soporta la query principal `where('roomId').orderBy('timestamp')` sin error de índice de Firestore.

---

## Validaciones en Reglas

| Campo | Validación en regla |
|-------|-------------------|
| `senderId` | Debe ser exactamente `request.auth.uid` (no se puede falsificar) |
| `text` | Tipo `string`, longitud `1..2000` caracteres |
| `roomId` | Tipo `string` (valor controlado por el cliente; validación de negocio en app) |
| `senderName` | Tipo `string` (el servidor no valida contenido; validación en app) |
| `timestamp` | Establecido via `FieldValue.serverTimestamp()` por el servidor (no validable en reglas directamente) |

---

## Notas de Seguridad

- **No se permite leer sin autenticación**: usuarios anónimos o sin sesión no pueden acceder a ningún mensaje.
- **Mensajes inmutables**: no hay operación `update` ni `delete` en v1. Esto previene edición o borrado de mensajes por cualquier usuario, incluyendo el propietario.
- **Límite de texto en regla**: el límite de 2000 caracteres en reglas de Firestore actúa como segunda línea de defensa; la app también valida antes de escribir.
- **Default deny**: cualquier colección no declarada está bloqueada explícitamente.
