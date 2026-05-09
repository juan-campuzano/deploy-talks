# Internal Contract: GeminiChatController

**Feature**: 004-basic-gemini-chatbot  
**Type**: Internal widget-service contract  
**Date**: 2026-05-08

---

## Overview

`GeminiChatController` is the single source of truth for the Gemini chatbot tab. The `GeminiChatPage` widget reads from it and calls its public methods. This document defines the contract between the UI layer and the controller.

---

## Public Interface

### Constructor

```dart
GeminiChatController({required String displayName})
```

- Creates a `GenerativeModel` (VertexAI, `gemini-2.5-flash`) with a personalised system instruction.
- Starts an initial `ChatSession`.
- Sets `isLoading = false`, `error = null`, `messages = []`.

---

### Properties (readable, notify on change)

| Property | Type | Guarantees |
|----------|------|-----------|
| `messages` | `List<GeminiMessage>` (unmodifiable view) | Ordered oldest-first; never null; may be empty |
| `isLoading` | `bool` | True only while `sendMessage` is in flight |
| `error` | `String?` | Non-null only when last operation failed; cleared on next `sendMessage` call |

---

### Methods

#### `Future<void> sendMessage(String text)`

**Precondition**: `!isLoading && text.trim().isNotEmpty`  
**Postcondition (success)**:
- A `GeminiMessage(role: user, text: text.trim())` is appended to `messages`
- A `GeminiMessage(role: model, text: reply)` is appended to `messages`
- `isLoading == false`, `error == null`

**Postcondition (failure)**:
- The user message is still appended (remains visible)
- `isLoading == false`, `error` is set to a human-readable description
- The `ChatSession` remains valid for subsequent calls

**Side effects**: Calls `notifyListeners()` at minimum three times — on user message append, on loading start, and on completion.

---

#### `void clearSession()`

**Precondition**: None (safe to call from any state including while loading)  
**Postcondition**:
- `messages` is empty
- A fresh `ChatSession` is created (prior history inaccessible to Gemini)
- `isLoading == false`, `error == null`

**Side effects**: Calls `notifyListeners()` once.

---

## UI Obligations

The `GeminiChatPage` widget MUST:

1. Disable the send button when `isLoading == true` or input text is empty
2. Show a loading indicator (e.g., `CircularProgressIndicator`) when `isLoading == true`
3. React to `error != null` by surfacing the error message to the user (SnackBar or inline chip)
4. Call `controller.dispose()` in `State.dispose()` (inherited from `ChangeNotifier`)

---

## Threading Contract

`sendMessage` is `async`. The controller MUST NOT be called from a non-main isolate. All `notifyListeners` calls happen on the main isolate.
