# Research: Basic Gemini Chatbot Tab

**Feature**: 004-basic-gemini-chatbot  
**Date**: 2026-05-08  
**Status**: Complete — all NEEDS CLARIFICATION resolved

---

## Decision 1: Multi-turn Chat API with `firebase_ai`

**Decision**: Use `GenerativeModel.startChat(history: [])` to obtain a `ChatSession`, then call `chatSession.sendMessage(Content.text(text))` for each turn. History is accumulated automatically by the SDK in the `ChatSession` object.

**Rationale**: The `firebase_ai` package (already installed at `^3.11.0`) wraps the Google Generative AI SDK with Firebase Auth integration. `startChat()` returns a `ChatSession` that internally maintains the turn history, so no manual history management is needed in app code. This mirrors the pattern already used in `AdminService` (`_model.generateContent([Content.text(prompt)])`) but uses the stateful `ChatSession` variant.

**Alternatives considered**:
- Manually reconstructing history as `List<Content>` on every call — rejected because `ChatSession` already does this and reduces boilerplate.
- Using `generateContentStream` for streaming responses — deferred to a future enhancement; synchronous `sendMessage` is simpler and sufficient for the demo.

**Code reference** (existing pattern in `admin_service.dart`):
```dart
_model = FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.5-flash');
final response = await _model.generateContent([Content.text(prompt)]);
```

**Multi-turn extension**:
```dart
final session = _model.startChat();
final response = await session.sendMessage(Content.text(userText));
final reply = response.text ?? '';
```

---

## Decision 2: Tab Navigation Structure

**Decision**: Introduce a new `HomePage` widget (rendered at the existing `/chat` route) that wraps a `DefaultTabController` + `TabBar` + `TabBarView`. Tab 0 = existing `ChatPage` (group chat). Tab 1 = new `GeminiChatPage`.

**Rationale**: `DefaultTabController` is the lowest-complexity Flutter tab solution — no external packages needed. The existing `/chat` route in `go_router` simply changes its `builder` from `ChatPage` to `HomePage`; all routing, redirect logic, and presence tracking in `ChatPage` remain completely unchanged.

**Alternatives considered**:
- `NavigationBar` (Material 3 bottom nav) — more prominent but heavier widget; `TabBar` is idiomatic for a 2–3 tab layout where all tabs are peers.
- `PageView` with manual index tracking — more code for no benefit; `TabBar`/`TabBarView` handles sync automatically.

---

## Decision 3: State Management for Gemini Chat

**Decision**: Create `GeminiChatController extends ChangeNotifier` (owned by `_GeminiChatPageState` via `initState`/`dispose`). It holds:
- `List<GeminiMessage> messages` — in-memory conversation history for UI display
- `bool isLoading` — controls send-button state and loading indicator
- `String? error` — last error message for display
- `ChatSession _session` — the live SDK session

**Rationale**: Consistent with the project's existing `provider` + `ChangeNotifier` pattern (`UserNotifier`, `AdminSessionNotifier`). Owned by the page state (not the provider tree) because the conversation is transient and per-session — it doesn't need to survive route changes or be shared across widgets.

**Alternatives considered**:
- Lifting `GeminiChatController` into the provider tree (alongside `ChatService`) — rejected; the chat session is ephemeral and page-local.
- Using `StreamController` — more complex for a request/response pattern that isn't truly streaming.

---

## Decision 4: Gemini Model Selection

**Decision**: Use `gemini-2.5-flash` — the same model already used in `AdminService`.

**Rationale**: Ensures consistent Firebase AI configuration; no additional IAM or model enablement required. Fast enough for interactive chat in a demo.

**Alternatives considered**: `gemini-2.0-flash` — slightly older; `gemini-2.5-flash` is already validated in this project.

---

## Decision 5: Conversation Persistence

**Decision**: In-memory only. The `GeminiChatController` and `ChatSession` are owned by `_GeminiChatPageState`. They are recreated on each page mount and discarded on dispose.

**Rationale**: The spec explicitly states no Firestore persistence is needed. For the demo scenario, resetting between app launches is acceptable. Tab switches do not remount the page because `TabBarView` uses `AutomaticKeepAliveClientMixin` by default when tabs are part of the same `DefaultTabController` — so the state survives tab switches within a session.

**Alternatives considered**: Persisting to Firestore — out of scope per spec; adds complexity and cost.

---

## Decision 6: System Prompt Personalisation

**Decision**: Include a minimal system prompt that names the assistant "Gemini" and mentions the user's display name for a personalised feel. Passed as `systemInstruction` parameter to `generativeModel(...)`.

**Rationale**: The spec notes this as optional (A-004) but it meaningfully improves demo quality with negligible extra complexity.

**Example**:
```dart
FirebaseAI.vertexAI().generativeModel(
  model: 'gemini-2.5-flash',
  systemInstruction: Content.system(
    'Eres un asistente amigable. El usuario se llama $displayName.',
  ),
);
```

---

## Decision 7: Error Handling Strategy

**Decision**: Catch exceptions in `GeminiChatController.sendMessage`, set `error` field, call `notifyListeners()`. The UI observes `error` and shows a `SnackBar` or inline error chip. The failed user message remains visible in the list so the user can see what they sent.

**Rationale**: Minimal, visible feedback without disrupting the chat history.

---

## All NEEDS CLARIFICATION Resolved

| Unknown | Resolution |
|---------|-----------|
| Multi-turn chat API | `ChatSession` via `model.startChat()` |
| Tab widget choice | `DefaultTabController` + `TabBar` |
| State scope | Page-local `ChangeNotifier` |
| Model | `gemini-2.5-flash` (existing) |
| Persistence | In-memory, session-scoped |
| System prompt | Optional personalisation via `systemInstruction` |
