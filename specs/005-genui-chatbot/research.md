# Research: GenUI Chatbot Tab

**Feature**: 005-genui-chatbot  
**Date**: 2026-05-08  
**Status**: Complete — all decisions resolved

---

## Decision 1: Branch Dependency on 004

**Decision**: This feature builds on top of `004-basic-gemini-chatbot`. The plan explicitly lists `HomePage` (2-tab shell), `GeminiChatPage`, and `GeminiChatController` as **prerequisites**. Implementation must occur after 004 is merged into main, OR this branch should be rebased/merged onto 004.

**Rationale**: Spec FR-001 requires extending the existing `HomePage` tab bar from 2 to 3 tabs. `HomePage` only exists in the 004 branch.

**Impact on tasks**: The first phase of task generation must include a "merge/rebase 004 prerequisite" gate.

---

## Decision 2: GenUI Catalog Architecture

**Decision**: Create a completely separate catalog called `buildGenuiChatbotCatalog()` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`. It defines 4 component types: `TextCard`, `ItemList`, `CodeBlock`, `StatHighlight`. The catalog has its own `catalogId` (`com.deploytalks.genui_chatbot_catalog`) and its own `systemPromptFragments`.

**Rationale**: The existing `chat_catalog` (`ChatBubble`) is used for deterministic rendering of group chat messages — its system prompt tells Gemini to render every message as a bubble. The new catalog needs a completely different system prompt that tells Gemini to pick the best component for each response. Sharing would create conflicting system instructions.

**Alternatives considered**:
- Adding components to the existing `chat_catalog` — rejected; would corrupt the group chat's rendering logic with incompatible system prompt fragments.
- A single shared catalog for all Gemini features — rejected for the same reason.

---

## Decision 3: SurfaceController Ownership

**Decision**: `GenuiChatController` (the page-local `ChangeNotifier` for the GenUI tab) owns its own `A2uiTransportAdapter`, `SurfaceController`, and `Catalog` instance. These are created in the constructor and disposed in `dispose()`.

**Rationale**: The global `GenuiService` provider is tightly coupled to the group chat's `ChatController`. Creating a separate stack for the GenUI chatbot avoids any cross-contamination of surfaces and session state. This matches Assumption A-003 in the spec and follows the same pattern used by `GeminiChatController` in 004 (page-local ownership).

**Code shape**:
```dart
class GenuiChatController extends ChangeNotifier {
  GenuiChatController({required String displayName}) {
    _catalog = buildGenuiChatbotCatalog();
    _transport = A2uiTransportAdapter();
    _surfaceController = SurfaceController(catalogs: [_catalog]);
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(...),
    );
    _session = _model.startChat(
      safetySettings: [],
    );
  }
  ...
}
```

---

## Decision 4: Conversation Entry Model

**Decision**: Use a sealed class `GenuiConversationEntry` with two subtypes:
- `GenuiUserEntry(String text, DateTime timestamp)` — rendered as a plain text bubble on the right
- `GenuiSurfaceEntry(String surfaceId, DateTime timestamp)` — rendered via `SurfaceView(surfaceId: surfaceId, controller: _surfaceController)` on the left

**Rationale**: A single `List<GenuiConversationEntry>` is simpler to manage than two parallel lists (one for user messages, one for surfaces). Sealed classes give exhaustive switches in the widget builder with no null risk.

**Alternatives considered**:
- `List<dynamic>` with runtime type checks — rejected; no type safety.
- Two separate lists — rejected; ordering would need manual interleaving.

---

## Decision 5: How Gemini Sends GenUI Responses

**Decision**: Use `_session.sendMessage(Content.text(userText))` — the same multi-turn `ChatSession` API from 004. The catalog's `systemPromptFragments` are appended to the model's system instruction at construction time via `generativeModel(..., systemInstruction: Content.system(combinedPrompt))`. The response comes back as A2UI JSON that GenUI's transport adapter processes automatically.

**Rationale**: The `genui` package's `Conversation` class normally wraps the full send/receive cycle. However, for chatbot use with `ChatSession` (multi-turn), we call `_session.sendMessage` directly and feed the raw response text into `_transport.addMessage(...)` as an A2UI protocol message. Inspecting the existing `GenuiService` confirms this pattern is viable — `A2uiTransportAdapter.addMessage` accepts protocol messages and drives the `SurfaceController`.

**Alternative**: Using `Conversation.send()` — the `Conversation` class manages its own Gemini model instance internally, which conflicts with our need for a `ChatSession` (multi-turn). Rejected.

**Practical flow**:
```
user types → _session.sendMessage(Content.text(text))
           → response.text contains A2UI JSON
           → _transport.addMessage(parseA2uiMessage(response.text))
           → SurfaceController updates surface
           → SurfaceView widget rebuilds
```

**Note**: If the GenUI package exposes a higher-level hook for `ChatSession`, that should be preferred. This will be validated during implementation.

---

## Decision 6: Catalog Component System Prompt

**Decision**: Craft a single `systemInstruction` string that:
1. Describes the assistant persona and the user's display name
2. Lists each catalog component with its schema (fields, types, descriptions)
3. Instructs Gemini to always respond with exactly one A2UI `createSurface` call using the most appropriate component

**Rationale**: GenUI's `systemPromptFragments` on the catalog are automatically assembled into the system prompt. But since we're using `ChatSession` with a custom `GenerativeModel`, we need to pass this as the `systemInstruction` parameter manually.

**Component selection rules in the prompt**:
- Question about a concept, explanation, summary → use `TextCard`
- Question with multiple items, rankings, steps → use `ItemList`
- Question involving code, commands, syntax → use `CodeBlock`
- Question about a single fact, stat, or number → use `StatHighlight`

---

## Decision 7: Tab Bar Extension (3 tabs)

**Decision**: Modify `HomePage` to `DefaultTabController(length: 3)` with a third `Tab(text: 'GenUI')` and a third `TabBarView` child `GenuiChatPage()`.

**Rationale**: Minimal change to the existing `HomePage` — just increment the length and add one entry to each list.

**Files modified**: `app/lib/features/home/home_page.dart` — 3 surgical edits.

---

## All Decisions Resolved

| Decision | Resolution |
|----------|-----------|
| Branch dependency | Must implement after / on top of 004 |
| Catalog isolation | New `buildGenuiChatbotCatalog()` with own catalogId |
| SurfaceController scope | Page-local in `GenuiChatController` |
| Conversation model | Sealed `GenuiConversationEntry` (user / surface) |
| Gemini send API | `ChatSession.sendMessage` + manual A2UI transport feed |
| System prompt | Single `systemInstruction` combining persona + catalog schema |
| Tab extension | `HomePage` length 2 → 3 |
