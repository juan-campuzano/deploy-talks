# Quickstart: GenUI Chatbot Tab

**Feature**: 005-genui-chatbot  
**Date**: 2026-05-08

---

## What This Feature Does

Adds a third tab **"GenUI"** to the home tab bar. Unlike the plain-text "Gemini" tab, the GenUI tab renders Gemini's responses as **rich UI components** chosen from a custom catalog. Each response is a live Flutter widget — a card, a list, a code block, or a stat highlight — rather than raw text.

---

## Prerequisites

This feature builds on top of `004-basic-gemini-chatbot`. The following must be in place before implementing this feature:

- `app/lib/features/home/home_page.dart` — `HomePage` with `DefaultTabController(length: 2)`
- `app/lib/features/gemini_chat/` — `GeminiChatPage`, `GeminiChatController`, bubble/input widgets
- `app/lib/models/gemini_message.dart` — `GeminiMessage`, `GeminiRole`
- `app/lib/router.dart` updated to use `HomePage`

---

## Files Created / Modified

### New files

```
app/lib/
├── models/
│   └── genui_conversation_entry.dart         # Sealed class: GenuiUserEntry / GenuiSurfaceEntry
├── features/
│   └── genui_chat/
│       ├── catalog/
│       │   └── genui_chatbot_catalog.dart    # buildGenuiChatbotCatalog(): 4 components
│       ├── genui_chat_controller.dart        # GenuiChatController (ChangeNotifier)
│       ├── genui_chat_page.dart              # StatefulWidget — GenUI chat UI
│       └── widgets/
│           └── genui_user_bubble.dart        # Plain right-aligned user message bubble
```

### Modified files

```
app/lib/
└── features/home/home_page.dart              # length 2→3, add 'GenUI' tab + GenuiChatPage()
```

---

## Running Locally

No new dependencies or Firebase configuration needed. All required packages (`genui`, `firebase_ai`, `provider`) are already in `pubspec.yaml`.

```bash
cd app
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=... \
  [other dart-defines as usual]
```

---

## Key Implementation Notes

### Sealed conversation entry

```dart
sealed class GenuiConversationEntry {
  const GenuiConversationEntry({required this.timestamp});
  final DateTime timestamp;
}

final class GenuiUserEntry extends GenuiConversationEntry {
  const GenuiUserEntry({required this.text, required super.timestamp});
  final String text;
}

final class GenuiSurfaceEntry extends GenuiConversationEntry {
  const GenuiSurfaceEntry({required this.surfaceId, required super.timestamp});
  final String surfaceId;
}
```

### Catalog construction (abbreviated)

```dart
Catalog buildGenuiChatbotCatalog() {
  return Catalog(
    [
      CatalogItem(name: 'TextCard',      dataSchema: ..., widgetBuilder: ...),
      CatalogItem(name: 'ItemList',      dataSchema: ..., widgetBuilder: ...),
      CatalogItem(name: 'CodeBlock',     dataSchema: ..., widgetBuilder: ...),
      CatalogItem(name: 'StatHighlight', dataSchema: ..., widgetBuilder: ...),
    ],
    catalogId: 'com.deploytalks.genui_chatbot_catalog',
    systemPromptFragments: [kGenuiSystemPrompt],
  );
}
```

### Controller initialisation

```dart
GenuiChatController({required String displayName}) {
  _catalog = buildGenuiChatbotCatalog();
  _transport = A2uiTransportAdapter();
  _surfaceController = SurfaceController(catalogs: [_catalog]);
  final systemPrompt = [
    'Eres un asistente útil. El usuario se llama $displayName.',
    ..._catalog.systemPromptFragments,
  ].join('\n\n');
  _model = FirebaseAI.vertexAI().generativeModel(
    model: 'gemini-2.5-flash',
    systemInstruction: Content.system(systemPrompt),
  );
  _session = _model.startChat();
}
```

### Rendering entries in the ListView

```dart
switch (entry) {
  case GenuiUserEntry(:final text):
    return Align(
      alignment: Alignment.centerRight,
      child: GenuiUserBubble(text: text),
    );
  case GenuiSurfaceEntry(:final surfaceId):
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SurfaceView(
          surfaceId: surfaceId,
          controller: controller.surfaceController,
        ),
      ),
    );
}
```

### Extending the tab bar in `home_page.dart`

```dart
// Before (004):
DefaultTabController(length: 2, ...)
tabs: [Tab(text: 'Chat Grupal'), Tab(text: 'Gemini')]
children: [ChatPage(), GeminiChatPage()]

// After (005):
DefaultTabController(length: 3, ...)
tabs: [Tab(text: 'Chat Grupal'), Tab(text: 'Gemini'), Tab(text: 'GenUI')]
children: [ChatPage(), GeminiChatPage(), GenuiChatPage()]
```

---

## No New Dependencies

| Package | Used for |
|---------|---------|
| `genui: ^0.9.0` | `Catalog`, `CatalogItem`, `SurfaceController`, `A2uiTransportAdapter`, `SurfaceView` |
| `json_schema_builder: ^0.1.3` | `ObjectSchema`, `Schema.string`, `Schema.boolean`, `Schema.array` |
| `firebase_ai: ^3.11.0` | `FirebaseAI.vertexAI()`, `GenerativeModel`, `ChatSession`, `Content` |
| `provider: ^6.1.5+1` | `ChangeNotifier` / `ListenableBuilder` |
