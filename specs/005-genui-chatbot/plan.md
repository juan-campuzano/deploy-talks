# Implementation Plan: GenUI Chatbot Tab

**Branch**: `005-genui-chatbot` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/005-genui-chatbot/spec.md`

## Summary

Add a third "GenUI" tab to the home tab bar. The tab hosts a 1-on-1 Gemini chatbot where responses are rendered as rich Flutter UI components (cards, lists, code blocks, stat highlights) via the `genui` package, rather than plain text. A new isolated catalog (`buildGenuiChatbotCatalog()`) defines 4 component types and a system prompt that instructs Gemini to always reply with a structured GenUI surface. State is fully in-memory; no Firestore writes. This feature extends the `HomePage` from 004 (2 tabs → 3 tabs).

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK ^3.11.5  
**Primary Dependencies**: `genui: ^0.9.0`, `json_schema_builder: ^0.1.3`, `firebase_ai: ^3.11.0`, `provider: ^6.1.5+1` — **all already in `pubspec.yaml`; no new dependencies**  
**Storage**: In-memory only (`GenuiChatController` fields + `SurfaceController` surfaces); no Firestore reads or writes  
**Testing**: `flutter_test` — unit tests for `GenuiConversationEntry` subtypes, `buildGenuiChatbotCatalog()` (item count + catalogId), `GenuiChatController.clearSession()`  
**Target Platform**: Flutter Web (primary), Android/iOS (secondary)  
**Project Type**: Mobile/Web app (Flutter)  
**Performance Goals**: First GenUI surface renders within 10s of send; loading indicator visible within 200ms  
**Constraints**: No new packages; existing group chat and Gemini tab regression-free; `GenuiService` provider untouched  
**Scale/Scope**: Demo — single user 1-on-1 with Gemini GenUI; up to 20 component surfaces per session

## Branch Dependency

**⚠️ IMPORTANT**: This branch was cut from `main` before `004-basic-gemini-chatbot` was merged. The following artifacts from `004` must be present before this feature can be implemented:

| Artifact | From |
|----------|------|
| `app/lib/features/home/home_page.dart` | 004 |
| `app/lib/features/gemini_chat/` (all files) | 004 |
| `app/lib/models/gemini_message.dart` | 004 |
| `app/lib/router.dart` updated to use `HomePage` | 004 |

**Resolution**: Rebase this branch onto `004-basic-gemini-chatbot` before starting implementation, or merge 004 into main first then re-branch.

## Constitution Check

*Constitution is a template with no concrete principles defined. No violations identifiable.*

| Gate | Status | Notes |
|------|--------|-------|
| No new dependencies | ✅ PASS | All required packages already installed |
| No over-engineering | ✅ PASS | Page-local controller, sealed entry type, 4-component catalog — all minimal |
| Existing features regression-free | ✅ PASS | `GenuiService` provider and `chat_catalog` untouched; `HomePage` modified minimally (length + 1 tab) |
| Isolation of GenUI stacks | ✅ PASS | New catalog and `SurfaceController` are page-local; no cross-contamination with group chat |

## Project Structure

### Documentation (this feature)

```text
specs/005-genui-chatbot/
├── plan.md                               # This file
├── research.md                           # Phase 0 — 7 decisions resolved
├── data-model.md                         # Phase 1 — sealed entry type, controller, 4 catalog components
├── quickstart.md                         # Phase 1 — setup, code snippets, file map
├── contracts/
│   ├── genui-chat-controller.md         # Phase 1 — UI↔controller contract
│   └── genui-chatbot-catalog.md         # Phase 1 — catalog schema contract
└── tasks.md                              # Phase 2 output (speckit.tasks)
```

### Source Code

```text
app/lib/
├── models/
│   ├── genui_conversation_entry.dart     # NEW — sealed class (GenuiUserEntry / GenuiSurfaceEntry)
│   └── gemini_message.dart               # EXISTS (from 004) — unchanged
├── features/
│   ├── home/
│   │   └── home_page.dart                # EXISTS (from 004) — MODIFIED: length 2→3, add GenUI tab
│   ├── gemini_chat/                      # EXISTS (from 004) — unchanged
│   └── genui_chat/
│       ├── catalog/
│       │   └── genui_chatbot_catalog.dart   # NEW — buildGenuiChatbotCatalog(), 4 CatalogItems
│       ├── genui_chat_controller.dart       # NEW — GenuiChatController (ChangeNotifier)
│       ├── genui_chat_page.dart             # NEW — StatefulWidget with AutomaticKeepAliveClientMixin
│       └── widgets/
│           └── genui_user_bubble.dart       # NEW — right-aligned plain text bubble for user messages
├── chat/           (unchanged)
├── admin/          (unchanged)
└── enter_name/     (unchanged)
```

**Structure Decision**: Flutter feature-by-folder layout, consistent with `features/chat/`, `features/admin/`, `features/gemini_chat/` (from 004).

## Complexity Tracking

*No constitution violations. Section not applicable.*
