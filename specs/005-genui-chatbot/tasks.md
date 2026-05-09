# Tasks: GenUI Chatbot Tab

**Input**: Design documents from `specs/005-genui-chatbot/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Organization**: Tasks are grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: US1 (GenUI render), US2 (catalog components), US3 (multi-turn), US4 (clear)

---

## Phase 1: Setup

**Purpose**: Ensure 004 artifacts are present and create the new feature directory skeleton.

- [x] T001 Verify that `app/lib/features/home/home_page.dart` and `app/lib/features/gemini_chat/` exist (from feature 004); if not, rebase this branch onto `004-basic-gemini-chatbot` before proceeding
- [x] T002 Create directory structure: `app/lib/features/genui_chat/`, `app/lib/features/genui_chat/catalog/`, `app/lib/features/genui_chat/widgets/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The sealed entry model and catalog are imported by every subsequent file — nothing can be built without them.

**⚠️ CRITICAL**: No user story implementation can begin until T003 and T004 are complete.

- [x] T003 Create sealed class `GenuiConversationEntry` with subtypes `GenuiUserEntry(text, timestamp)` and `GenuiSurfaceEntry(surfaceId, timestamp)` in `app/lib/models/genui_conversation_entry.dart`
- [x] T004 [P] Create `buildGenuiChatbotCatalog()` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: define the 4 `CatalogItem` entries (`TextCard`, `ItemList`, `CodeBlock`, `StatHighlight`) with their `ObjectSchema` field definitions (per the catalog contract) and a `kGenuiSystemPrompt` constant that instructs Gemini to always respond with the most appropriate catalog component; set `catalogId: 'com.deploytalks.genui_chatbot_catalog'`

**Checkpoint**: Model + catalog compile — user story phases can begin.

---

## Phase 3: User Story 1 — Gemini Responds with Rich UI Components (Priority: P1) 🎯 MVP

**Goal**: A user opens the GenUI tab, sends a message, and sees Gemini's response rendered as a GenUI component surface — not raw text.

**Independent Test**: Open the GenUI tab, type "dame un resumen de los planetas del sistema solar", verify the response renders as a structured UI surface (not plain text).

### Implementation for User Story 1

- [x] T005 [P] [US1] Create `GenuiChatController extends ChangeNotifier` in `app/lib/features/genui_chat/genui_chat_controller.dart`: constructor takes `displayName`; builds catalog, `A2uiTransportAdapter`, `SurfaceController`; creates `GenerativeModel` (VertexAI, `gemini-2.5-flash`) with combined `systemInstruction` (persona + catalog `systemPromptFragments`); starts `ChatSession`; exposes `entries`, `isLoading`, `error`, `surfaceController`; implements `sendMessage(text)` — appends `GenuiUserEntry`, sets `isLoading = true`, awaits `_session.sendMessage`, feeds response into `_transport`, appends `GenuiSurfaceEntry`, handles errors; implements `clearSession()`
- [x] T006 [P] [US1] Create `GenuiUserBubble` stateless widget in `app/lib/features/genui_chat/widgets/genui_user_bubble.dart`: takes a `String text`; renders a right-aligned chat bubble using `AppColors.primary` background, white text, `Plus Jakarta Sans` 14px, rounded corners (matching the style of `GeminiMessageBubble` from 004)
- [x] T007 [US1] Create `GenuiChatPage` stateful widget in `app/lib/features/genui_chat/genui_chat_page.dart`: owns `GeminiChatController` lifecycle; reads `UserNotifier.value.displayName`; renders a `Scaffold` with: an `AppBar` showing "GenUI" label + gradient icon + clear `IconButton`; a `LinearProgressIndicator` when `isLoading`; a `ListView.builder` over `controller.entries` using a sealed `switch` — `GenuiUserEntry` → right-aligned `GenuiUserBubble`, `GenuiSurfaceEntry` → left-aligned `SurfaceView(surfaceId, controller: controller.surfaceController)`; a `GeminiInputBar` at the bottom (reuse from 004); auto-scroll on new entries; `SnackBar` on error; `AutomaticKeepAliveClientMixin` with `wantKeepAlive = true`
- [x] T008 [US1] Add `GenuiChatPage` as the third tab in `app/lib/features/home/home_page.dart`: change `DefaultTabController(length: 2)` → `length: 3`; add `Tab(text: 'GenUI')` to the `TabBar`; add `GenuiChatPage()` as the third child of `TabBarView`; add the import

**Checkpoint**: US1 complete — GenUI tab appears, user message shows as bubble, Gemini response renders as a surface.

---

## Phase 4: User Story 2 — Component Catalog with Multiple Component Types (Priority: P1)

**Goal**: Each catalog component type has a distinctive, styled Flutter widget that renders correctly when Gemini chooses it.

**Independent Test**: Ask "explícame qué es una API REST" → verify `TextCard` + `CodeBlock` surface renders. Ask "dame 5 frutas" → verify `ItemList` renders. Ask "cuántos km tiene el ecuador?" → verify `StatHighlight` renders.

### Implementation for User Story 2

- [x] T009 [P] [US2] Implement the `TextCard` `widgetBuilder` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: renders a `Container` with `AppColors.surface` background, left border in `AppColors.primary` (width 3), `Syne` bold title, `Plus Jakarta Sans` body text in `AppColors.textPrimary`, optional emoji in top-right corner; max width 520
- [x] T010 [P] [US2] Implement the `ItemList` `widgetBuilder` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: renders a `Container` card; optional `Syne` heading; each item on its own `Row` with an `AppColors.accent` bullet (•) or auto-incrementing number if `ordered == true`; `Plus Jakarta Sans` item text in `AppColors.textPrimary`
- [x] T011 [P] [US2] Implement the `CodeBlock` `widgetBuilder` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: renders a `Container` with `AppColors.surfaceEl` background; top row shows language pill (`AppColors.primaryBright` chip) if provided; code text in monospace font (`Courier New` or system mono) at 13px in `AppColors.textPrimary`; optional `caption` below in `AppColors.textSecondary` `Plus Jakarta Sans`
- [x] T012 [P] [US2] Implement the `StatHighlight` `widgetBuilder` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: renders a `Container` card with a large `Syne` display value (28px, `AppColors.primaryBright`) + inline `unit` if present; `label` above in `AppColors.textSecondary` 12px; optional `context` below in `AppColors.textMuted` 12px

**Checkpoint**: US2 complete — all 4 component types render correctly for their intended content types.

---

## Phase 5: User Story 3 — Multi-turn GenUI Conversation (Priority: P2)

**Goal**: The `ChatSession` in `GenuiChatController` maintains conversation context across turns, and `AutomaticKeepAliveClientMixin` preserves the full entry list + surfaces across tab switches.

**Independent Test**: Ask "dame los 3 países más grandes del mundo", switch to Chat Grupal, return to GenUI, ask "¿y cuál tiene más población de esos tres?" — verify Gemini's reply references the prior answer.

### Implementation for User Story 3

- [x] T013 [US3] Verify that `GenuiChatPage` correctly uses `AutomaticKeepAliveClientMixin` (added in T007) and that `wantKeepAlive` returns `true` — the `SurfaceView` widgets must remain mounted across tab switches so their surface registrations in `SurfaceController` stay valid; add explicit `super.build(context)` call at the top of `build()` per Flutter requirements for this mixin

**Checkpoint**: US3 complete — tab switching preserves conversation history and surfaces.

---

## Phase 6: User Story 4 — Clear GenUI Conversation (Priority: P3)

**Goal**: The clear button disposes all rendered surfaces and starts a fresh Gemini session with no memory of prior turns.

**Independent Test**: After 3+ turns, tap the clear button — verify the ListView is empty; send "¿Qué dijimos antes?" — verify Gemini has no context.

### Implementation for User Story 4

- [x] T014 [US4] Verify `GenuiChatController.clearSession()` (implemented in T005) correctly: empties `_entries`, disposes and recreates `_surfaceController` (a fresh `SurfaceController(catalogs: [_catalog])`), restarts `_session = _model.startChat()`, resets `isLoading = false` and `error = null`, calls `notifyListeners()`; confirm the clear `IconButton` in the `AppBar` (added in T007) is disabled when `entries.isEmpty`

**Checkpoint**: US4 complete — clear resets everything.

---

## Final Phase: Polish & Cross-cutting Concerns

- [x] T015 [P] Add empty-state widget in `GenuiChatPage` (`app/lib/features/genui_chat/genui_chat_page.dart`): when `entries` is empty, show a centered column with a gradient icon (`Icons.auto_awesome_mosaic`) and text "Pregúntale algo a Gemini ✨" in `AppColors.textMuted`
- [x] T016 [P] Add padding and border decoration to each catalog component widget in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart`: each widget `Container` should have `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4)` and `border: Border.all(color: AppColors.border)` with `borderRadius: BorderRadius.circular(12)`, `padding: EdgeInsets.all(14)`, so all 4 components feel visually unified
- [x] T017 Run `flutter analyze --no-pub` in `app/` and fix any errors; confirm 0 errors (pre-existing `withOpacity` info warnings from other files are acceptable); smoke-test that Chat Grupal and Gemini tabs show no regressions

---

## Dependencies (Story Completion Order)

```
T001 (verify 004 artifacts)
  └── T002 (create directories)
        ├── T003 (GenuiConversationEntry sealed class)  [BLOCKING for US1–US4]
        └── T004 (catalog skeleton + schemas)           [BLOCKING for US2 widget builders]
              │
              ├── T005 (GenuiChatController)  [P with T006]
              ├── T006 (GenuiUserBubble)      [P with T005]
              │
              └── T005+T006 done → T007 (GenuiChatPage)
                    └── T008 (wire into HomePage) → US1 DONE ✅
                          │
                          ├── T009, T010, T011, T012 [P] → US2 DONE ✅
                          │
                          └── T013 (verify keep-alive) → US3 DONE ✅
                                └── T014 (verify clearSession) → US4 DONE ✅
                                      └── T015, T016, T017 (polish)
```

## Parallel Execution Opportunities

**Foundational parallel group** (after T002): T003 and T004 are independent files:
- Agent A → `genui_conversation_entry.dart` (T003)
- Agent B → `genui_chatbot_catalog.dart` skeleton + schemas (T004)

**US1 parallel group** (after T003 + T004): T005 and T006 touch separate files:
- Agent A → `genui_chat_controller.dart` (T005)
- Agent B → `genui_user_bubble.dart` (T006)

**US2 parallel group** (after T007): T009–T012 each implement one `widgetBuilder` in the same file but in independent functions — they can be reviewed/merged in parallel:
- Agents A/B/C/D → one `widgetBuilder` each (T009, T010, T011, T012)

**Polish parallel group**: T015 (empty state) and T016 (card decoration) are independent.

## Implementation Strategy

**MVP scope**: Phase 1 + Phase 2 + Phase 3 (T001–T008) — delivers a functional GenUI tab with surfaces rendering (even if widget builders are stubs returning `Text('...')`).

**Incremental delivery**:
1. T001–T004: Skeleton + catalog compiles ✅
2. T005–T008: Full GenUI tab wired up, surfaces render ✅
3. T009–T012: All 4 component widgets polished ✅
4. T013–T014: Context retention + clear verified ✅
5. T015–T017: Empty state, decoration, smoke test ✅

## Summary

| Metric | Count |
|--------|-------|
| Total tasks | 17 |
| Phase 1 (Setup) | 2 |
| Phase 2 (Foundation) | 2 |
| US1 tasks | 4 |
| US2 tasks | 4 |
| US3 tasks | 1 |
| US4 tasks | 1 |
| Polish tasks | 3 |
| Parallelizable `[P]` tasks | 9 |
| MVP boundary | T001–T008 (8 tasks) |
