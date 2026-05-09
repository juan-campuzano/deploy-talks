# Data Model: Basic Gemini Chatbot Tab

**Feature**: 004-basic-gemini-chatbot  
**Date**: 2026-05-08

---

## Entities

### GeminiMessage

Represents a single turn (one side of the conversation) displayed in the Gemini chat UI.

| Field | Type | Description |
|-------|------|-------------|
| `role` | `GeminiRole` (enum: `user`, `model`) | Who authored this message |
| `text` | `String` | Display text of the message |
| `timestamp` | `DateTime` | Wall-clock time the message was created (local) |

**Validation rules**:
- `text` must be non-empty (enforced at send-time by the UI; empty messages are rejected).
- `timestamp` is set at object creation time; it is not derived from Gemini's response (the SDK doesn't return timestamps).

**State lifecycle**: Immutable once created. Messages are only added, never mutated or removed (except on session clear).

---

### GeminiChatController (ChangeNotifier)

The in-memory session state for the Gemini chatbot. Owned by `_GeminiChatPageState`.

| Field | Type | Description |
|-------|------|-------------|
| `messages` | `List<GeminiMessage>` | Ordered conversation history (oldest first) |
| `isLoading` | `bool` | True while awaiting a Gemini response |
| `error` | `String?` | Last error message; null when no error |
| `_session` | `ChatSession` (firebase_ai) | The live multi-turn SDK session; private |

**Operations**:
- `sendMessage(String text)` → `Future<void>` — appends user message, calls SDK, appends model response, handles errors
- `clearSession()` → resets `messages` to `[]`, creates a new `ChatSession`, clears any error
- `_model` (private `GenerativeModel`) — created once with `systemInstruction`; `_session` is derived from it

**State transitions**:

```
idle ─── sendMessage() ──→ loading ─── SDK success ──→ idle (message appended)
                      │              └── SDK error  ──→ error state (idle)
                      │
clearSession() resets to idle from any state
```

---

### GeminiRole (enum)

```dart
enum GeminiRole { user, model }
```

Used to drive UI layout (user messages align right; model messages align left) and map to the firebase_ai `Content` role strings (`'user'` / `'model'`).

---

## Data Flow

```
User types text
      │
      ▼
GeminiChatController.sendMessage(text)
      │
      ├─→ append GeminiMessage(role: user, text: text, timestamp: now)
      ├─→ isLoading = true  →  notifyListeners()
      │
      ▼
ChatSession.sendMessage(Content.text(text))   [firebase_ai SDK]
      │
      ├── success ──→ response.text
      │         ├─→ append GeminiMessage(role: model, text: response.text)
      │         └─→ isLoading = false  →  notifyListeners()
      │
      └── error  ──→ error = e.toString()
                └─→ isLoading = false  →  notifyListeners()
```

---

## Relationship to Existing Models

| Existing model | Relationship |
|----------------|-------------|
| `ChatMessage` | Unrelated — used only by the group chat; `GeminiMessage` is a new, separate type |
| `AppUser` | `GeminiChatController` reads `AppUser.displayName` once at construction to personalise the system prompt |
| `ChatBackground` | Unrelated — background is set globally via Firestore; the Gemini tab respects the same background |

---

## No Firestore Persistence

`GeminiMessage` instances exist only in `GeminiChatController.messages` (heap). They are discarded when the page is disposed or `clearSession()` is called. No Firestore collection is created for this feature.
