# Internal Contract: GenuiChatController

**Feature**: 005-genui-chatbot  
**Type**: Internal widget-service contract  
**Date**: 2026-05-08

---

## Overview

`GenuiChatController` is the single source of truth for the GenUI chatbot tab. `GenuiChatPage` reads from it and calls its public methods. This document defines the contract between the UI layer and the controller, including what the UI must guarantee and what the controller guarantees in return.

---

## Constructor

```dart
GenuiChatController({required String displayName})
```

**Post-conditions**:
- `buildGenuiChatbotCatalog()` is called once; the resulting `Catalog` is stored
- `A2uiTransportAdapter`, `SurfaceController`, `GenerativeModel`, and `ChatSession` are all created and ready
- `entries` is empty, `isLoading == false`, `error == null`

---

## Public API

### Properties

| Property | Type | Guarantees |
|----------|------|-----------|
| `entries` | `List<GenuiConversationEntry>` (unmodifiable view) | Ordered oldest-first; never null; may be empty |
| `isLoading` | `bool` | True only while `sendMessage` is in flight |
| `error` | `String?` | Non-null only when the last operation failed; cleared on next `sendMessage` |
| `surfaceController` | `SurfaceController` | The controller to pass to every `SurfaceView`; valid until `dispose()` |

---

### `Future<void> sendMessage(String text)`

**Precondition**: `!isLoading && text.trim().isNotEmpty`

**Postcondition (success)**:
- A `GenuiUserEntry(text: text.trim())` is appended to `entries`
- A `GenuiSurfaceEntry(surfaceId: ...)` is appended to `entries`
- The surface is registered in `surfaceController` and renderable via `SurfaceView`
- `isLoading == false`, `error == null`

**Postcondition (failure)**:
- The `GenuiUserEntry` is still appended (remains visible)
- No `GenuiSurfaceEntry` is appended for the failed turn
- `isLoading == false`, `error` is set to a human-readable string
- The `ChatSession` remains valid for subsequent calls

**`notifyListeners()` call count**: ≥ 2 (on user entry append + loading start, then on completion)

---

### `void clearSession()`

**Precondition**: None (safe to call from any state)

**Postcondition**:
- `entries` is empty
- `surfaceController` is reset (all prior surface registrations cleared)
- A fresh `ChatSession` is started (Gemini has no memory of prior conversation)
- `isLoading == false`, `error == null`

**`notifyListeners()` call count**: 1

---

## UI Obligations

`GenuiChatPage` MUST:

1. Pass `controller.surfaceController` to every `SurfaceView` — never create a separate `SurfaceController` instance
2. Disable the send button when `isLoading == true` or input text is empty
3. Show a loading indicator when `isLoading == true`
4. React to `error != null` by surfacing it to the user (SnackBar)
5. Call `controller.dispose()` inside `State.dispose()` (inherited from `ChangeNotifier`)
6. Render `GenuiUserEntry` as a right-aligned plain text bubble
7. Render `GenuiSurfaceEntry` as a left-aligned `SurfaceView(surfaceId: entry.surfaceId, controller: controller.surfaceController)`

---

## Catalog Contract

`buildGenuiChatbotCatalog()` MUST return a `Catalog` with:
- `catalogId` = `'com.deploytalks.genui_chatbot_catalog'`
- Exactly 4 `CatalogItem` entries: `TextCard`, `ItemList`, `CodeBlock`, `StatHighlight`
- `systemPromptFragments` that instruct Gemini on which component to use for which type of answer

The catalog MUST NOT include `ChatBubble` — that component belongs exclusively to the group chat catalog.

---

## Lifecycle

```
GenuiChatController()     ← created in State.initState()
      │
      ├── sendMessage()   ← called per user turn
      ├── clearSession()  ← called on clear button tap
      │
      ▼
dispose()                 ← called in State.dispose()
  └── _transport.dispose()
  └── super.dispose()     (ChangeNotifier cleanup)
```
