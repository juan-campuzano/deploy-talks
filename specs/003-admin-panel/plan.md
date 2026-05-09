# Implementation Plan: Admin Panel

**Branch**: `003-admin-panel` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/003-admin-panel/spec.md`

## Summary

Añadir un panel de administración protegido por contraseña en la ruta `/admin` de la app Flutter. El panel expone tres operaciones: limpiar el historial del chat (batch delete en Firestore), ver usuarios conectados en tiempo real (stream de la colección `presence`), y generar un background personalizado con IA (Gemini via `firebase_ai` ya instalado → resultado persistido en `settings/chat_background` y sincronizado a todos los clientes en tiempo real). La contraseña se pasa como `--dart-define=ADMIN_PASSWORD=xxx` en tiempo de build; la sesión es exclusivamente in-memory.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK ^3.11.5  
**Primary Dependencies**: `firebase_ai: ^3.11.0` (Gemini), `cloud_firestore: ^6.3.0`, `go_router: ^17.2.3`, `provider: ^6.1.5+1` — todas ya en `pubspec.yaml`, sin dependencias nuevas  
**Storage**: Firestore — colección `messages` (existente), `presence` (existente), `settings` (nueva)  
**Testing**: `flutter_test` (unit tests de `AdminService`, `AdminSessionNotifier`, `ChatBackground.fromFirestore`)  
**Target Platform**: Flutter Web (primary), Android/iOS (secondary)  
**Project Type**: Mobile/Web app (Flutter)  
**Performance Goals**: Limpieza de chat <2s propagada; background actualizado <5s tras respuesta de Gemini; lista de presencia actualizada <3s  
**Constraints**: Sin dependencias nuevas; contraseña nunca en el repositorio; sesión admin no persiste entre recargas  
**Scale/Scope**: Demo personal — decenas de usuarios concurrentes, <500 mensajes por sesión

## Constitution Check

*La constitución del proyecto está en formato de plantilla sin principios concretos definidos. Sin violaciones identificables. Todos los gates pasan.*

| Gate | Estado | Notas |
|------|--------|-------|
| Sin dependencias nuevas | ✅ PASS | `firebase_ai` ya instalado; todas las dependencias existentes |
| Sin over-engineering | ✅ PASS | Sesión admin in-memory, contraseña vía dart-define, sin Cloud Functions |
| Seguridad en boundaries | ✅ PASS | Validación de contraseña en pantalla de login; Firestore rules actualizadas |
| Propagación en tiempo real | ✅ PASS | Background y presencia via Firestore streams existentes |

## Project Structure

### Documentation (this feature)

```text
specs/003-admin-panel/
├── plan.md              ← este archivo
├── research.md          ← Phase 0 ✅
├── data-model.md        ← Phase 1 ✅
├── quickstart.md        ← Phase 1 ✅
├── contracts/
│   └── admin-service-contract.md  ← Phase 1 ✅
└── tasks.md             ← generado por /speckit.tasks (pendiente)
```

### Source Code (app/)

```text
app/lib/
├── features/
│   ├── admin/                          ← NUEVO
│   │   ├── admin_login_page.dart       ← pantalla de login con contraseña
│   │   ├── admin_dashboard_page.dart   ← panel principal
│   │   ├── admin_session_notifier.dart ← ValueNotifier<bool>
│   │   └── widgets/
│   │       ├── connected_users_card.dart     ← lista de presencia
│   │       ├── clear_chat_card.dart          ← botón + confirmación
│   │       └── background_prompt_card.dart   ← input + generación IA
│   ├── chat/
│   │   ├── chat_page.dart    ← MODIFICADO: añadir background stream
│   │   └── ...               ← sin cambios
│   └── enter_name/
│       └── ...               ← sin cambios
├── models/
│   ├── chat_background.dart  ← NUEVO
│   ├── presence_record.dart  ← NUEVO
│   ├── app_user.dart         ← sin cambios
│   └── chat_message.dart     ← sin cambios
└── services/
    ├── admin_service.dart    ← NUEVO (clear + background generate/stream)
    ├── presence_service.dart ← MODIFICADO: añadir connectedUsersStream()
    ├── chat_service.dart     ← sin cambios
    └── genui_service.dart    ← sin cambios

app/test/
└── admin/
    ├── admin_session_notifier_test.dart
    ├── admin_service_test.dart
    └── chat_background_test.dart
```

**Archivos raíz modificados**:
- `app/lib/router.dart` — añadir ruta `/admin` + guard admin
- `app/lib/main.dart` — añadir `AdminSessionNotifier` y `AdminService` como Providers
- `firestore.rules` — añadir regla lectura/escritura para `settings`

**Structure Decision**: Proyecto Flutter único bajo `app/`. Nueva feature `admin` como directorio en `features/` siguiendo la convención existente. Nuevos modelos y servicios al mismo nivel que los existentes.
