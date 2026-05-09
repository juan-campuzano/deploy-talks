# Implementation Plan: Basic Gemini Chatbot Tab

**Branch**: `004-basic-gemini-chatbot` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/004-basic-gemini-chatbot/spec.md`

## Summary

Convert the single-screen chat into a two-tab layout (Chat Grupal + Gemini). The Gemini tab provides a 1-on-1 conversational chatbot backed by `firebase_ai` → VertexAI (`gemini-2.5-flash`), using `ChatSession` for automatic multi-turn context management. All state is in-memory; no Firestore writes. The router's `/chat` route switches its builder from `ChatPage` to a new `HomePage` wrapper.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK ^3.11.5  
**Primary Dependencies**: `firebase_ai: ^3.11.0` (Gemini + VertexAI), `provider: ^6.1.5+1`, `go_router: ^17.2.3` — all already in `pubspec.yaml`, **no new dependencies**  
**Storage**: In-memory only (`GeminiChatController` fields); no Firestore reads or writes  
**Testing**: `flutter_test` — unit tests for `GeminiMessage`, `GeminiChatController` (mocked `ChatSession`)  
**Target Platform**: Flutter Web (primary), Android/iOS (secondary)  
**Project Type**: Mobile/Web app (Flutter)  
**Performance Goals**: First Gemini response within 10s; loading indicator visible within 200ms of send  
**Constraints**: No new packages; conversation history in-memory only; existing group chat must be regression-free  
**Scale/Scope**: Demo — single user 1-on-1 with Gemini; up to 20 turns per session

## Constitution Check

*Constitution is a template with no concrete principles defined. No violations identifiable.*

| Gate | Status | Notes |
|------|--------|-------|
| No new dependencies | ✅ PASS | `firebase_ai` already installed; `ChatSession` is part of existing package |
| No over-engineering | ✅ PASS | Page-local `ChangeNotifier`, in-memory state, `DefaultTabController` (zero new packages) |
| Regression-free | ✅ PASS | `ChatPage` is embedded unchanged inside `TabBarView`; router redirect logic untouched |

## Project Structure

### Documentation (this feature)

```text
specs/004-basic-gemini-chatbot/
├── plan.md                           # This file
├── research.md                       # Phase 0 — all unknowns resolved
├── data-model.md                     # Phase 1 — GeminiMessage, GeminiChatController
├── quickstart.md                     # Phase 1 — setup, code snippets, file map
├── contracts/
│   └── gemini-chat-controller.md    # Phase 1 — UI↔controller contract
└── tasks.md                          # Phase 2 output (speckit.tasks)
```

### Source Code

```text
app/lib/
├── models/
│   ├── gemini_message.dart           # NEW — GeminiRole enum + GeminiMessage value type
│   └── (existing models unchanged)
├── features/
│   ├── home/
│   │   └── home_page.dart            # NEW — DefaultTabController wrapper (2 tabs)
│   ├── gemini_chat/
│   │   ├── gemini_chat_controller.dart  # NEW — ChangeNotifier: messages, isLoading, error, session
│   │   ├── gemini_chat_page.dart        # NEW — StatefulWidget, owns controller lifecycle
│   │   └── widgets/
│   │       ├── gemini_message_bubble.dart   # NEW — user/model bubble
│   │       └── gemini_input_bar.dart        # NEW — text field + send button
│   ├── chat/       (unchanged)
│   ├── admin/      (unchanged)
│   └── enter_name/ (unchanged)
├── router.dart                        # MODIFIED — /chat builder: ChatPage → HomePage
└── (all other files unchanged)
```

**Structure Decision**: Flutter feature-by-folder layout, consistent with existing `features/chat/` and `features/admin/` pattern.

## Complexity Tracking

*No constitution violations. Section not applicable.*
