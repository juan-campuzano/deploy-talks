# Implementation Plan: Flutter Web Chat con Burbujas Generadas por IA

**Branch**: `001-firebase-genui-chat` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-firebase-genui-chat/spec.md`

## Summary

Aplicación Flutter web de chat en tiempo real con Firebase Firestore como backend de mensajes y Firebase Authentication para identidad de usuarios. Las respuestas generadas por IA se renderizan como superficies dinámicas usando el paquete `genui` (v0.9.0), que interpreta estructuras A2UI producidas por un LLM (Firebase Vertex AI) y las convierte en widgets Flutter. Los mensajes del usuario se persisten en Firestore y se muestran en la UI; las respuestas del asistente llegan como streams del LLM y se renderizan como `Surface` widgets del framework `genui`.

## Technical Context

**Language/Version**: Dart 3.11.5 / Flutter 3.41.8  
**Primary Dependencies**: `genui ^0.9.0`, `firebase_core`, `firebase_auth` (solo Anonymous Auth), `cloud_firestore`, `firebase_vertexai` (LLM para `genui`), `go_router`  
**Storage**: Firebase Firestore (mensajes), Firebase Authentication (identidad)  
**Testing**: `flutter_test` (widget tests), `fake_cloud_firestore` (mocks Firestore), `firebase_auth_mocks`  
**Target Platform**: Flutter Web (Chrome, Firefox, Safari, Edge)  
**Project Type**: Web application (SPA Flutter)  
**Performance Goals**: Mensajes visibles en < 2 segundos; historial de hasta 500 mensajes sin degradación visible  
**Constraints**: Solo web en v1; sin soporte offline en v1; identificación por nombre libre + Anonymous Auth (sin contraseñas)  
**Scale/Scope**: Sala de chat única pública en v1; ~50 usuarios concurrentes esperados

## Constitution Check

*GATE: Re-verificado post Phase 1 design.*

La constitución del proyecto está en estado de plantilla (sin principios definidos aún). No existen gates activos que bloqueen el avance. Se aplican los principios de ingeniería estándar:

| Gate | Estado | Notas |
|------|--------|-------|
| Simplicidad de estructura | ✅ PASS | Proyecto único Flutter, sin monorepo innecesario |
| Dependencias justificadas | ✅ PASS | Cada dependencia tiene un rol exclusivo y no redundante |
| Scope acotado a spec | ✅ PASS | Sin features adicionales fuera del spec |

## Project Structure

### Documentation (this feature)

```text
specs/001-firebase-genui-chat/
├── plan.md              # Este archivo
├── research.md          # Phase 0: decisiones técnicas y alternativas evaluadas
├── data-model.md        # Phase 1: entidades, esquemas Firestore, estados
├── quickstart.md        # Phase 1: guía de configuración Firebase + primer run
├── contracts/           # Phase 1: contratos de interfaz (Firestore rules, auth flows)
└── tasks.md             # Phase 2 (pendiente: /speckit.tasks)
```

### Source Code (repository root)

```text
app/
├── lib/
│   ├── main.dart                        # Entry point, Firebase init, router setup
│   ├── firebase_options.dart            # FlutterFire CLI generated config
│   ├── router.dart                      # go_router: /login, /chat routes + auth guard
│   ├── models/
│   │   ├── chat_message.dart            # Modelo inmutable de mensaje (Firestore ↔ Dart)
│   │   └── app_user.dart                # Modelo de usuario autenticado
│   ├── services/
│   │   ├── auth_service.dart            # Abstracción Firebase Auth (register/login/logout)
│   │   ├── chat_service.dart            # Abstracción Firestore (enviar/escuchar mensajes)
│   │   └── genui_service.dart           # Orquestación genui: Conversation, Transport, LLM
│   ├── features/
│   │   ├── enter_name/
│   │   │   ├── enter_name_page.dart         # Pantalla de entrada de nombre de usuario
│   │   │   └── user_notifier.dart           # ValueNotifier<AppUser?> — fuente de verdad del nombre
│   │   └── chat/
│   │       ├── chat_page.dart           # Pantalla principal del chat
│   │       ├── chat_controller.dart     # Estado del chat (mensajes Firestore → superficies gen_ui)
│   │       ├── widgets/
│   │       │   ├── genui_bubble.dart          # Wrapper de Surface(gen_ui) para cualquier mensaje
│   │       │   ├── message_input.dart         # Campo de texto + botón enviar
│   │       │   └── chat_list.dart             # ListView de superficies gen_ui con auto-scroll
│   │       └── catalog/
│   │           └── chat_catalog.dart    # ChatBubble CatalogItem (isOwn, content, senderName)
├── test/
│   ├── models/
│   │   └── chat_message_test.dart
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   └── chat_service_test.dart
│   └── features/
│       ├── auth/
│       │   └── login_page_test.dart
│       └── chat/
│           └── chat_page_test.dart
├── web/
│   └── index.html                       # Firebase JS SDK ya incluido (FlutterFire)
└── pubspec.yaml
```

**Structure Decision**: Proyecto único Flutter (ya existente en `app/`). Se adopta arquitectura por features dentro de `lib/features/` con servicios compartidos en `lib/services/`. No se requiere backend separado ya que Firebase y Vertex AI son servicios administrados.

## Complexity Tracking

> No hay violaciones de gates activos que requieran justificación.
