# Quickstart: Basic Gemini Chatbot Tab

**Feature**: 004-basic-gemini-chatbot  
**Date**: 2026-05-08

---

## What This Feature Does

Converts the single-screen chat into a **two-tab layout**:

| Tab | Content |
|-----|---------|
| Chat Grupal | Existing real-time group chat (unchanged) |
| Gemini | 1-on-1 AI chatbot powered by Gemini via VertexAI |

---

## Files Created / Modified

### New files

```
app/lib/
├── models/
│   └── gemini_message.dart             # GeminiMessage + GeminiRole
├── features/
│   ├── home/
│   │   └── home_page.dart              # Two-tab wrapper (TabBar + TabBarView)
│   └── gemini_chat/
│       ├── gemini_chat_controller.dart # ChangeNotifier: messages, isLoading, error
│       ├── gemini_chat_page.dart       # StatefulWidget — Gemini chatbot UI
│       └── widgets/
│           ├── gemini_message_bubble.dart  # Chat bubble (user / model)
│           └── gemini_input_bar.dart       # Text field + send button
```

### Modified files

```
app/lib/
└── router.dart     # /chat route builder: ChatPage → HomePage
```

---

## Running Locally

No new environment variables or Firebase configuration required. The `firebase_ai` package is already installed and configured.

```bash
cd app
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_APP_ID=...
```

---

## Key Implementation Notes

### Initialising the Gemini session

```dart
// In gemini_chat_controller.dart
_model = FirebaseAI.vertexAI().generativeModel(
  model: 'gemini-2.5-flash',
  systemInstruction: Content.system(
    'Eres un asistente amigable llamado Gemini. El usuario se llama $displayName.',
  ),
);
_session = _model.startChat();
```

### Sending a message

```dart
Future<void> sendMessage(String text) async {
  // 1. Append user message
  messages.add(GeminiMessage(role: GeminiRole.user, text: text.trim(), timestamp: DateTime.now()));
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    // 2. Call Gemini
    final response = await _session.sendMessage(Content.text(text.trim()));
    final reply = response.text ?? 'Sin respuesta';
    messages.add(GeminiMessage(role: GeminiRole.model, text: reply, timestamp: DateTime.now()));
  } catch (e) {
    error = 'Error: ${e.toString()}';
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
```

### Wiring the tabs in `router.dart`

```dart
// Before:
GoRoute(path: '/chat', builder: (context, state) => const ChatPage())

// After:
GoRoute(path: '/chat', builder: (context, state) => const HomePage())
```

### Tab bar setup in `home_page.dart`

```dart
DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
      bottom: const TabBar(
        tabs: [Tab(text: 'Chat Grupal'), Tab(text: 'Gemini')],
      ),
    ),
    body: TabBarView(
      children: [ChatPage(), GeminiChatPage()],
    ),
  ),
)
```

> Note: `ChatPage` already manages its own `Scaffold`-level concerns (gradient background). Extract the `AppBar` from `ChatPage` if needed to avoid double `Scaffold`, or use a `Builder`-based composition.

---

## Testing

```bash
cd app
flutter test
```

Unit tests cover:
- `GeminiMessage` construction and field values
- `GeminiChatController.clearSession()` resets state
- `GeminiChatController.sendMessage()` with a mocked `ChatSession` — success and error paths

---

## No New Dependencies

All required packages are already in `pubspec.yaml`:

| Package | Used for |
|---------|---------|
| `firebase_ai: ^3.11.0` | `FirebaseAI.vertexAI()`, `GenerativeModel`, `ChatSession`, `Content` |
| `provider: ^6.1.5+1` | `ChangeNotifier` / `ListenableBuilder` for controller |
| `go_router: ^17.2.3` | Route change (`/chat` → `HomePage`) |
