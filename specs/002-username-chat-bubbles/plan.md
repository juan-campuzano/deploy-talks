# Implementation Plan: Username en Burbujas de Chat

**Branch**: `002-username-chat-bubbles` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/002-username-chat-bubbles/spec.md`

## Summary

Mostrar el nombre del remitente encima de **todas** las burbujas de chat (propias y ajenas). Actualmente el `ChatBubble` widget ya recibe `senderName` como prop, pero la condición `if (!isOwn)` en el `widgetBuilder` de `chat_catalog.dart` suprime el nombre en los mensajes propios. El cambio se limita a eliminar esa condición y ajustar el padding para burbujas derechas. Sin cambios en modelo de datos, servicios ni infraestructura.

## Technical Context

**Language/Version**: Dart 3 / Flutter 3.x  
**Primary Dependencies**: genui (superficies declarativas), firebase_firestore, firebase_auth, provider  
**Storage**: Firestore — colección `messages` (campos `senderName` y `senderId` ya presentes)  
**Testing**: flutter_test (widget tests)  
**Target Platform**: Web (Flutter Web), también soporta Android/iOS  
**Project Type**: Mobile/Web app (Flutter)  
**Performance Goals**: Renderizado de burbuja < 16ms (60 fps en scroll)  
**Constraints**: Sin cambios de esquema Firestore; compatible con mensajes históricos existentes  
**Scale/Scope**: Sala pública única, ~500 mensajes máx por sesión

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

La constitución del proyecto no ha sido configurada (contiene solo placeholders). No hay gates formales que evaluar. El cambio es de una sola línea en un único archivo de UI; no introduce nuevas dependencias, capas de abstracción ni complejidad arquitectural. **PASS**.

## Project Structure

### Documentation (this feature)

```text
specs/002-username-chat-bubbles/
├── plan.md         ← este archivo
├── spec.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md        ← generado por /speckit.tasks
```

### Source Code (único archivo a modificar)

```text
app/
└── lib/
    └── features/
        └── chat/
            └── catalog/
                └── chat_catalog.dart   ← único archivo a cambiar
```

**Structure Decision**: Single Flutter app (`app/`). El cambio es puramente de presentación dentro del `widgetBuilder` del `ChatBubble` catalog item. No se añaden archivos.

## Complexity Tracking

No hay violaciones. Cambio mínimo en UI, sin nuevas capas ni dependencias.
