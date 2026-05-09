# Data Model: Admin Panel

**Feature**: 003-admin-panel  
**Date**: 2026-05-08

---

## Entidades Nuevas

### 1. `ChatBackground`

Representa el fondo activo del chat, generado por IA y visible para todos los usuarios.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `colors` | `List<String>` | Sí | Lista de 2–4 colores hexadecimales (ej. `["#1a1a2e", "#16213e"]`) |
| `angle` | `int` | Sí | Ángulo de rotación del gradiente en grados (0–360) |
| `label` | `String` | Sí | Descripción corta en español (máx 30 chars), generada por la IA |
| `prompt` | `String` | Sí | Prompt original ingresado por el administrador |
| `updatedAt` | `DateTime` | Sí | Timestamp de la última actualización |

**Reglas de validación**:
- `colors`: debe tener entre 2 y 4 elementos; cada elemento debe ser un color hex válido (`#rrggbb`)
- `angle`: debe estar entre 0 y 360
- `label`: máx 30 caracteres
- `prompt`: no vacío

**Estado inicial**: El documento puede no existir (sin fondo personalizado → fondo por defecto del sistema)

**Persistencia**: Documento único en Firestore: `settings/chat_background`

---

### 2. `PresenceRecord`

Extiende la información de presencia existente para exponer la lista completa de usuarios al admin.

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `sessionId` | `String` | Sí | ID único de la sesión (también es el ID del documento Firestore) |
| `displayName` | `String` | Sí | Nombre del usuario tal como se ingresó en `EnterNamePage` |
| `joinedAt` | `DateTime` | Sí | Timestamp de cuando el usuario se unió |

**Persistencia**: Colección `presence` en Firestore (ya existe). Cada documento tiene `sessionId` como ID.

---

### 3. `AdminSession`

Representa el estado de autenticación del administrador. Vive solo en memoria; no se persiste en Firebase ni en disco.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `isAuthenticated` | `bool` | `true` si el admin ingresó la contraseña correcta en esta sesión |

**Reglas**:
- `isAuthenticated` se convierte en `true` solo cuando el hash de la contraseña ingresada coincide con el hash de `ADMIN_PASSWORD` (compile-time constant)
- Se reinicia a `false` al cerrar/recargar la app (no persiste)

---

## Entidades Modificadas

### `ChatMessage` (existente)

No se agregan campos. La operación de "limpiar chat" elimina físicamente los documentos de la colección `messages` (hard delete).

### `PresenceService` (existente)

Se añade un método `connectedUsersStream()` que retorna `Stream<List<PresenceRecord>>`. No se modifica el esquema de datos existente.

---

## Estructura de Firestore (nueva colección/documento)

```
firestore/
├── messages/          (existente — sin cambios de schema)
├── presence/          (existente — sin cambios de schema)
└── settings/          ← NUEVA colección
    └── chat_background  ← documento único
        ├── colors: ["#hex1", "#hex2"]
        ├── angle: 135
        ├── label: "Espacio oscuro"
        ├── prompt: "fondo espacial oscuro"
        └── updatedAt: Timestamp
```

---

## Transiciones de Estado

### Flujo del background

```
[Sin fondo] → [Generando] → [Fondo aplicado]
                  ↓ (error)
             [Error: fondo anterior intacto]
```

### Flujo de sesión admin

```
[No autenticado] → [Ingresa contraseña] → [Autenticado]
                         ↓ (incorrecta)
                   [Error: intento fallido]
```

### Flujo de limpieza del chat

```
[Con mensajes] → [Confirma] → [Borrando (batch)] → [Chat vacío]
                    ↓ (cancela)
             [Sin cambios]
```
