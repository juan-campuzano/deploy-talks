# Data Model: GenUI Chatbot Tab

**Feature**: 005-genui-chatbot  
**Date**: 2026-05-08

---

## Entities

### GenuiConversationEntry (sealed class)

Represents a single entry in the GenUI chatbot's conversation list. It is either a message the user typed, or a GenUI surface that Gemini rendered.

```dart
sealed class GenuiConversationEntry {
  const GenuiConversationEntry({required this.timestamp});
  final DateTime timestamp;
}
```

#### Subtype: GenuiUserEntry

| Field | Type | Description |
|-------|------|-------------|
| `text` | `String` | The user's raw input text |
| `timestamp` | `DateTime` | Wall-clock time when the message was sent |

Rendered as: a plain text bubble aligned right (using the existing `GeminiMessageBubble` widget with `GeminiRole.user`, or a purpose-built equivalent).

#### Subtype: GenuiSurfaceEntry

| Field | Type | Description |
|-------|------|-------------|
| `surfaceId` | `String` | The unique surface ID registered in `SurfaceController` |
| `timestamp` | `DateTime` | Wall-clock time when the surface was created |

Rendered as: `SurfaceView(surfaceId: surfaceId, controller: _surfaceController)` aligned left.

**State lifecycle**: Immutable once created. Entries are only appended; they are never mutated. On `clearSession()` the list is replaced with an empty list.

---

### GenuiChatController (ChangeNotifier)

The in-memory session state for the GenUI chatbot. Owned by `_GenuiChatPageState`.

| Field | Type | Description |
|-------|------|-------------|
| `_entries` | `List<GenuiConversationEntry>` | Ordered conversation history (oldest first) |
| `isLoading` | `bool` | True while awaiting Gemini's response |
| `error` | `String?` | Last error; null when none |
| `_catalog` | `Catalog` | The GenUI chatbot catalog (private) |
| `_transport` | `A2uiTransportAdapter` | Feeds A2UI messages from Gemini to the surface controller (private) |
| `_surfaceController` | `SurfaceController` | Manages active surfaces; passed to `SurfaceView` widgets (private, but exposed as getter) |
| `_model` | `GenerativeModel` | VertexAI model with system instruction (private) |
| `_session` | `ChatSession` | Multi-turn session; recreated on `clearSession()` (private) |
| `_surfaceCounter` | `int` | Auto-incrementing counter for generating unique surface IDs (private) |

**Exposed getter**:
```dart
SurfaceController get surfaceController => _surfaceController;
List<GenuiConversationEntry> get entries => List.unmodifiable(_entries);
```

**Operations**:

- `sendMessage(String text)` → `Future<void>`
  1. Appends `GenuiUserEntry` to `_entries`
  2. Sets `isLoading = true`, clears `error`
  3. Calls `notifyListeners()`
  4. Awaits `_session.sendMessage(Content.text(text))`
  5. Creates a new unique `surfaceId = 'genui-$_surfaceCounter'`; increments counter
  6. Feeds response text into transport as A2UI protocol message
  7. Appends `GenuiSurfaceEntry(surfaceId: surfaceId)` to `_entries`
  8. Sets `isLoading = false`, calls `notifyListeners()`

- `clearSession()` → `void`
  1. Clears `_entries`
  2. Resets `_session = _model.startChat()`
  3. Resets `_surfaceController` (disposes old, creates new with same catalog)
  4. Resets `isLoading = false`, `error = null`
  5. Calls `notifyListeners()`

**Disposal**: `dispose()` calls `_transport.dispose()` and then `super.dispose()`.

---

### Catalog Components (defined in `buildGenuiChatbotCatalog()`)

These are GenUI `CatalogItem` definitions — they describe the data schema and Flutter widget builder for each component type Gemini can use.

#### TextCard

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | `String` | ✅ | Short heading for the card |
| `body` | `String` | ✅ | Main prose content |
| `emoji` | `String` | ❌ | Optional decorative emoji |

Rendered as: a dark surface card with `Syne` title text, `Plus Jakarta Sans` body text, left border accent in `AppColors.primary`.

#### ItemList

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | `String` | ❌ | Optional heading for the list |
| `items` | `List<String>` | ✅ | Ordered list of text items |
| `ordered` | `bool` | ❌ | If true, show numbered list; default false (bullet) |

Rendered as: a card with each item on its own row, a bullet or number indicator in `AppColors.accent`, `Plus Jakarta Sans` body text.

#### CodeBlock

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `language` | `String` | ❌ | Language label (e.g. "dart", "bash") |
| `code` | `String` | ✅ | The code or command text |
| `caption` | `String` | ❌ | Optional explanation below the block |

Rendered as: a `surfaceEl`-background block with monospace font, language pill label in `AppColors.primaryBright`, optional caption in `textSecondary`.

#### StatHighlight

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | `String` | ✅ | Short description of the stat |
| `value` | `String` | ✅ | The prominent number or fact |
| `unit` | `String` | ❌ | Optional unit (e.g. "km", "%") |
| `context` | `String` | ❌ | Optional one-line context sentence |

Rendered as: a card with a large `Syne` display value, smaller label above, optional unit inline, optional context below in `textMuted`.

---

## Data Flow

```
User types text
      │
      ▼
GenuiChatController.sendMessage(text)
      │
      ├─→ append GenuiUserEntry(text)
      ├─→ isLoading = true → notifyListeners()
      │
      ▼
ChatSession.sendMessage(Content.text(text))   [firebase_ai SDK]
      │
      ├── success ──→ response.text  (A2UI JSON from Gemini)
      │         ├─→ surfaceId = 'genui-$_surfaceCounter++'
      │         ├─→ _transport.addMessage(...)  [feeds A2UI into SurfaceController]
      │         ├─→ append GenuiSurfaceEntry(surfaceId)
      │         └─→ isLoading = false → notifyListeners()
      │
      └── error  ──→ error = 'Error al contactar a Gemini.'
                └─→ isLoading = false → notifyListeners()

GenuiChatPage.build()
      │
      └─→ ListView of GenuiConversationEntry
            ├── GenuiUserEntry  → UserBubble(text)
            └── GenuiSurfaceEntry → SurfaceView(surfaceId, controller: _surfaceController)
```

---

## Relationship to Existing Models

| Existing entity | Relationship |
|-----------------|-------------|
| `GeminiMessage` (004) | Unrelated — used by basic Gemini tab only; `GenuiConversationEntry` is a distinct sealed class |
| `ChatMessage` | Unrelated — Firestore group chat only; GenUI tab is in-memory |
| `AppUser` | `GenuiChatController` reads `AppUser.displayName` once at construction for system prompt personalisation |
| `GenuiService` (existing) | Untouched — the global `GenuiService` provider continues to serve the group chat's `ChatController` exclusively |
| `chat_catalog` (`ChatBubble`) | Untouched — the new catalog is a separate instance with different components and system prompt |

---

## No Firestore Persistence

All `GenuiConversationEntry` instances and `SurfaceController` surfaces exist in heap memory only. No Firestore reads or writes are introduced by this feature.
